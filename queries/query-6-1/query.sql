CREATE TEMP FUNCTION PtEtaPhiM2PxPyPzE(pepm STRUCT<Pt FLOAT64, Eta FLOAT64, Phi FLOAT64, Mass FLOAT64>) AS
  (STRUCT(pepm.Pt * cos(pepm.Phi) AS x,
          pepm.Pt * sin(pepm.Phi) AS y,
          pepm.Pt * sinh(pepm.Eta) AS z,
          sqrt((pepm.Pt * cosh(pepm.Eta))*(pepm.Pt * cosh(pepm.Eta)) + pepm.Mass * pepm.Mass) AS e));
CREATE TEMP FUNCTION RhoZ2Eta(Rho FLOAT64, Z FLOAT64) AS
  (log(Z/Rho + sqrt(Z/Rho * Z/Rho + 1.0)));
CREATE TEMP FUNCTION PxPyPzE2PtEtaPhiM(xyzt STRUCT<X FLOAT64, Y FLOAT64, Z FLOAT64, T FLOAT64>) AS
  (STRUCT(sqrt(xyzt.X*xyzt.X + xyzt.Y*xyzt.Y) AS Pt,
          RhoZ2Eta(sqrt(xyzt.X*xyzt.X + xyzt.Y*xyzt.Y), xyzt.z) AS Eta,
          CASE WHEN (xyzt.X = 0.0 AND xyzt.Y = 0.0) THEN 0 ELSE atan2(xyzt.Y, xyzt.X) END AS Phi,
          sqrt(xyzt.T*xyzt.T - xyzt.X*xyzt.X - xyzt.Y*xyzt.Y - xyzt.Z*xyzt.Z) AS Mass));
CREATE TEMP FUNCTION AddPxPyPzE2(
    xyzt1 STRUCT<X FLOAT64, Y FLOAT64, Z FLOAT64, T FLOAT64>,
    xyzt2 STRUCT<X FLOAT64, Y FLOAT64, Z FLOAT64, T FLOAT64>) AS
  (STRUCT(xyzt1.X + xyzt2.X AS X,
          xyzt1.Y + xyzt2.Y AS Y,
          xyzt1.Z + xyzt2.Z AS Z,
          xyzt1.T + xyzt2.T AS T));
CREATE TEMP FUNCTION AddPxPyPzE3(
    xyzt1 STRUCT<X FLOAT64, Y FLOAT64, Z FLOAT64, T FLOAT64>,
    xyzt2 STRUCT<X FLOAT64, Y FLOAT64, Z FLOAT64, T FLOAT64>,
    xyzt3 STRUCT<X FLOAT64, Y FLOAT64, Z FLOAT64, T FLOAT64>) AS
  (AddPxPyPzE2(xyzt1, AddPxPyPzE2(xyzt2, xyzt3)));
CREATE TEMP FUNCTION AddPtEtaPhiM2(
    pepm1 STRUCT<Pt FLOAT64, Eta FLOAT64, Phi FLOAT64, Mass FLOAT64>,
    pepm2 STRUCT<Pt FLOAT64, Eta FLOAT64, Phi FLOAT64, Mass FLOAT64>) AS
  (PxPyPzE2PtEtaPhiM(
     AddPxPyPzE2(
       PtEtaPhiM2PxPyPzE(pepm1),
       PtEtaPhiM2PxPyPzE(pepm2))));
CREATE TEMP FUNCTION AddPtEtaPhiM3(
    pepm1 STRUCT<Pt FLOAT64, Eta FLOAT64, Phi FLOAT64, Mass FLOAT64>,
    pepm2 STRUCT<Pt FLOAT64, Eta FLOAT64, Phi FLOAT64, Mass FLOAT64>,
    pepm3 STRUCT<Pt FLOAT64, Eta FLOAT64, Phi FLOAT64, Mass FLOAT64>) AS
  (PxPyPzE2PtEtaPhiM(
     AddPxPyPzE3(
       PtEtaPhiM2PxPyPzE(pepm1),
       PtEtaPhiM2PxPyPzE(pepm2),
       PtEtaPhiM2PxPyPzE(pepm3))));
CREATE TEMP FUNCTION TriJetMass(
    Jet1 STRUCT<Pt FLOAT64, Eta FLOAT64, Phi FLOAT64, Mass FLOAT64>,
    Jet2 STRUCT<Pt FLOAT64, Eta FLOAT64, Phi FLOAT64, Mass FLOAT64>,
    Jet3 STRUCT<Pt FLOAT64, Eta FLOAT64, Phi FLOAT64, Mass FLOAT64>) AS
  (AddPtEtaPhiM3(Jet1, Jet2, Jet3).Mass);
CREATE TEMP FUNCTION Norm(pepm STRUCT<Pt FLOAT64, Eta FLOAT64, Phi FLOAT64, Mass FLOAT64>) AS
  (sqrt(pepm.Pt*pepm.Pt + pepm.Eta*pepm.Eta + pepm.Phi*pepm.Phi + pepm.Mass*pepm.Mass));
CREATE TEMP FUNCTION Distance(v1 STRUCT<Pt FLOAT64, Eta FLOAT64, Phi FLOAT64, Mass FLOAT64>,
                              v2 STRUCT<Pt FLOAT64, Eta FLOAT64, Phi FLOAT64, Mass FLOAT64>) AS
  (Norm(STRUCT(v1.Pt - v2.Pt, v1.Eta - v2.Eta, v1.Phi - v2.Phi, v1.Mass - v2.Mass)));
WITH RunWithTriJets AS (
  SELECT *,
    (SELECT [j1, j2, j3]
     FROM UNNEST(Jet) j1 WITH OFFSET i,
          UNNEST(Jet) j2 WITH OFFSET j,
          UNNEST(Jet) j3 WITH OFFSET k
     WHERE i < j AND j < k
     ORDER BY abs(TriJetMass(STRUCT(j1.Pt, j1.Eta, j1.Phi, j1.Mass),
                             STRUCT(j2.Pt, j2.Eta, j2.Phi, j2.Mass),
                             STRUCT(j3.Pt, j3.Eta, j3.Phi, j3.Mass)) - 172.5) ASC
     LIMIT 1) AS TriJet
  FROM `{bigquery_dataset}.{input_table}`
  WHERE nJet >= 3
)
SELECT
  CAST((
    CASE
      WHEN tj.Pt < 15 THEN 15
      WHEN tj.Pt > 40 THEN 40
      ELSE tj.Pt
    END - 0.125) / 0.25 AS INT64) * 0.25 + 0.125 AS x,
  COUNT(*) AS y
FROM RunWithTriJets
CROSS JOIN UNNEST(TriJet) AS tj
GROUP BY x
ORDER BY x

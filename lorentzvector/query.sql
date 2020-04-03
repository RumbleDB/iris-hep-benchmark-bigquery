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
WITH ConversionTests AS (
  SELECT
    Distance(
      STRUCT(i,j,k,l),
      PxPyPzE2PtEtaPhiM(PtEtaPhiM2PxPyPzE(STRUCT(i,j,k,l)))) < 10e-14 AS outcome
  FROM UNNEST(GENERATE_ARRAY(1,3)) AS i,
       UNNEST(GENERATE_ARRAY(1,3)) AS j,
       UNNEST(GENERATE_ARRAY(1,3)) AS k,
       UNNEST(GENERATE_ARRAY(1,3)) AS l
),
AdditionTests AS (
  SELECT AddPxPyPzE2(STRUCT(1, 1, 1, 1), STRUCT(1, 1, 1, 1)) = STRUCT(2, 2, 2, 2) UNION ALL
  SELECT AddPxPyPzE2(STRUCT(0, 0, 0, 0), STRUCT(1, 1, 1, 1)) = STRUCT(1, 1, 1, 1) UNION ALL
  SELECT AddPxPyPzE2(STRUCT(1, 2, 3, 4), STRUCT(4, 3, 2, 1)) = STRUCT(5, 5, 5, 5) UNION ALL
  SELECT AddPxPyPzE3(STRUCT(1, 1, 1, 1),
                     STRUCT(1, 1, 1, 1),
                     STRUCT(1, 1, 1, 1)) = STRUCT(3, 3, 3, 3) UNION ALL
  SELECT Distance(AddPtEtaPhiM2(STRUCT(1, 1, 1, 1), STRUCT(1, 1, 1, 1)),
                  STRUCT(2, 1, 1, 2)) < 10e-14 UNION ALL
  SELECT Distance(AddPtEtaPhiM2(STRUCT(0.5, 1, 1.5, 2), STRUCT(3, 2, 1, 0)),
                  STRUCT(3.447136157112324, 1.917038257310314, 1.069595855582019, 6.080260775883978)) < 10e-14 UNION ALL
  SELECT Distance(AddPtEtaPhiM2(STRUCT(0.5, 1, 1.5, 2), STRUCT(1, 1, 1, 1)),
                  STRUCT(1.458623516158427, 1.021427505465948, 1.165090670378742, 3.259561057534407)) < 10e-14 UNION ALL
  SELECT Distance(AddPtEtaPhiM3(STRUCT(0.5, 1, 1.5, 2), STRUCT(1, 1, 1, 1), STRUCT(2, 1.5, 1, 0.5)),
                  STRUCT(3.447136157112324, 1.324295084525344, 1.069595855582019, 5.271610723174633)) < 10e-14
)
SELECT CAST(outcome AS INT64) AS x, COUNT(*) AS y
FROM (
  SELECT * FROM ConversionTests UNION ALL
  SELECT * FROM AdditionTests
)
GROUP BY x
ORDER BY x

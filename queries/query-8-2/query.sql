WITH Leptons AS (
  SELECT
    *,
    nMuon + nElectron AS nLepton,
    ARRAY(
      SELECT AS STRUCT
        Pt, Eta, Phi, Mass, Charge, "m" AS Type
      FROM UNNEST(Muon)
      UNION ALL
      SELECT AS STRUCT
        Pt, Eta, Phi, Mass, Charge, "e" AS Type
      FROM UNNEST(Electron)
    ) AS Lepton
  FROM `{bigquery_dataset}.{input_table}`
),
TriLeptionsWithOtherLepton AS (
  SELECT
    *,
    (
      SELECT AS STRUCT
        i1, i2,
        (
          SELECT AS STRUCT
            *
          FROM UNNEST(Lepton) l3 WITH OFFSET i3
          WHERE i3 <> i1 AND i3 <> i2
          ORDER BY l3.Pt DESC
          LIMIT 1
        ) AS otherLepton,
        AddPtEtaPhiM2(STRUCT(l1.Pt, l1.Eta, l1.Phi, l1.Mass),
                      STRUCT(l2.Pt, l2.Eta, l2.Phi, l2.Mass)) AS Dilepton
      FROM UNNEST(Lepton) l1 WITH OFFSET i1,
           UNNEST(Lepton) l2 WITH OFFSET i2
      WHERE
        i1 < i2 AND
        l1.charge = -l2.charge AND
        l1.type   =  l2.type
      ORDER BY
        ABS(AddPtEtaPhiM2(STRUCT(l1.Pt, l1.Eta, l1.Phi, l1.Mass),
                          STRUCT(l2.Pt, l2.Eta, l2.Phi, l2.Mass)).Mass - 91.2) ASC
      LIMIT 1
    ) AS BestTriLepton
  FROM Leptons
  WHERE nLepton >= 3
),
TriLeptionsWithMassAndOtherLepton AS (
  SELECT
    *,
    SQRT(2 * MET_pt * BestTriLepton.otherLepton.Pt *
         (1.0 - COS(DeltaPhi(STRUCT(MET_phi AS Phi),
                             BestTriLepton.otherLepton)))) AS transverseMass
  FROM TriLeptionsWithOtherLepton
  WHERE BestTriLepton IS NOT NULL
)
SELECT
  CAST((
    CASE
      WHEN BestTriLepton.otherLepton.pt < 15 THEN 14.999
      WHEN BestTriLepton.otherLepton.pt > 60 THEN 60
      ELSE BestTriLepton.otherLepton.pt
    END - 0.225) / 0.45 AS INT64) * 0.45 + 0.225 AS x,
  COUNT(*) AS y
FROM TriLeptionsWithMassAndOtherLepton
WHERE BestTriLepton.otherLepton.pt IS NOT NULL
GROUP BY x
ORDER BY x

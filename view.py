

"""
SELECT *,
  ARRAY(SELECT AS STRUCT
          Jet_pt.list[OFFSET(i)].element AS pt,
          Jet_eta.list[OFFSET(i)].element AS eta,
          Jet_phi.list[OFFSET(i)].element AS phi,
          Jet_mass.list[OFFSET(i)].element AS mass,
          Jet_puId.list[OFFSET(i)].element AS puId,
          Jet_btag.list[OFFSET(i)].element AS btag
        FROM UNNEST(Jet_pt.list)WITH OFFSET i
        ) AS Jet
FROM root_playground.Run2012B_SingleMu_small
CROSS JOIN UNNEST(Jet_pt.list) AS Jet_pt_list
"""

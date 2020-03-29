

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
        ) AS Jet,
  ARRAY(SELECT AS STRUCT
          Muon_pt.list[OFFSET(i)].element AS pt,
          Muon_eta.list[OFFSET(i)].element AS eta,
          Muon_phi.list[OFFSET(i)].element AS phi,
          Muon_mass.list[OFFSET(i)].element AS mass,
          Muon_charge.list[OFFSET(i)].element AS charge,
          Muon_pfRelIso03_all.list[OFFSET(i)].element AS pfRelIso03_all,
          Muon_pfRelIso04_all.list[OFFSET(i)].element AS pfRelIso04_all,
          Muon_tightId.list[OFFSET(i)].element AS tightId,
          Muon_softId.list[OFFSET(i)].element AS softId,
          Muon_dxy.list[OFFSET(i)].element AS dxy,
          Muon_dxyErr.list[OFFSET(i)].element AS dxyErr,
          Muon_dz.list[OFFSET(i)].element AS dz,
          Muon_dzErr.list[OFFSET(i)].element AS dzErr,
          Muon_jetIdx.list[OFFSET(i)].element AS jetIdx,
          Muon_genPartIdx.list[OFFSET(i)].element AS genPartIdx
        FROM UNNEST(Muon_pt.list)WITH OFFSET i
        ) AS Muon
FROM cloud-shared-execution.root_playground.Run2012B_SingleMu_small
CROSS JOIN UNNEST(Jet_pt.list) AS Jet_pt_list
"""

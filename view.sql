SELECT *,
  ARRAY(SELECT AS STRUCT
          Jet_pt.list[OFFSET(i)].element AS pt,
          Jet_eta.list[OFFSET(i)].element AS eta,
          Jet_phi.list[OFFSET(i)].element AS phi,
          Jet_mass.list[OFFSET(i)].element AS mass,
          Jet_puId.list[OFFSET(i)].element AS puId,
          Jet_btag.list[OFFSET(i)].element AS btag
        FROM UNNEST(Jet_pt.list) WITH OFFSET i
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
        FROM UNNEST(Muon_pt.list) WITH OFFSET i
        ) AS Muon,
  ARRAY(SELECT AS STRUCT
          Electron_pt.list[OFFSET(i)].element AS pt,
          Electron_eta.list[OFFSET(i)].element AS eta,
          Electron_phi.list[OFFSET(i)].element AS phi,
          Electron_mass.list[OFFSET(i)].element AS mass,
          Electron_charge.list[OFFSET(i)].element AS charge,
          Electron_pfRelIso03_all.list[OFFSET(i)].element AS pfRelIso03_all,
          Electron_dxy.list[OFFSET(i)].element AS dxy,
          Electron_dxyErr.list[OFFSET(i)].element AS dxyErr,
          Electron_dz.list[OFFSET(i)].element AS dz,
          Electron_dzErr.list[OFFSET(i)].element AS dzErr,
          Electron_cutBasedId.list[OFFSET(i)].element AS cutBasedId,
          Electron_pfId.list[OFFSET(i)].element AS pfId,
          Electron_jetIdx.list[OFFSET(i)].element AS jetIdx,
          Electron_genPartIdx.list[OFFSET(i)].element AS genPartIdx
        FROM UNNEST(Electron_pt.list) WITH OFFSET i
        ) AS Electron
FROM cloud-shared-execution.root_playground.Run2012B_SingleMu_small

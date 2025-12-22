# Scripts to prepare 3D meshes for calculating distances

---
## Symbiont to cell surface

`prep_mesh.py`
Prepares mesh by splittin each individual symboint cell for calculation
`prep_external.py`
Prepares an external bounding box of object exterior, in case of gaps. 
`calc_dist.py`
Runs calculation of distacne from each individual symbiont cell to the closest target "other" mesh (cell surface)
`run_calc_v2.sh`
wrapper runnning the python scripts together

---

## Symbiont-to-symbiont distance
`calc_symbiont_distance.py`
Runs calculation specificaly for distance between two symbionts
`run_symbiont_v_symbiont_calc`
wrapper runnning the python scripts together
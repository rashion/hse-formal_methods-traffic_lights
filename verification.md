# Verifying a Traffic Light Controller
---

## Safety checks

Lauch command:

```bash
spin -search -a -ltl safety -O3 -w26 -m100000000 traffic-lights-9-simple.pml
```

Output:

```
ltl safety: [] ((((! (((p_light==green)) && (((es_light==green)) || ((sw_ne_light==green))))) && (! (((ns_light==green)) && (((sw_ne_light==green)) || ((es_light==green)))))) && (! (((es_light==green)) && ((((sw_ne_light==green)) || ((ns_light==green))) || ((p_light==green)))))) && (! (((sw_ne_light==green)) && ((((ns_light==green)) || ((es_light==green))) || ((p_light==green))))))
ltl liveness: ((([] ((! (((len(ns_sense)>0)) && ((ns_light==red)))) || (<> ((ns_light==green))))) && ([] ((! (((len(es_sense)>0)) && ((es_light==red)))) || (<> ((es_light==green)))))) && ([] ((! (((len(sw_ne_sense)>0)) && ((sw_ne_light==red)))) || (<> ((sw_ne_light==green)))))) && ([] ((! (((len(p_sense)>0)) && ((p_light==red)))) || (<> ((p_light==green)))))
ltl fairness: ((([] (<> (! (((ns_light==green)) && ((ns_sense==1)))))) && ([] (<> (! (((es_light==green)) && ((es_sense==1))))))) && ([] (<> (! (((sw_ne_light==green)) && ((sw_ne_sense==1))))))) && ([] (<> (! (((p_light==green)) && ((p_sense==1))))))
  the model contains 3 never claims: fairness, liveness, safety
  only one claim is used in a verification run
  choose which one with ./pan -a -N name (defaults to -N safety)
  or use e.g.: spin -search -ltl safety traffic-lights-9-simple.pml
pan: ltl formula safety
Depth= 1445069 States=    1e+06 Transitions= 2.85e+06 Memory=   816.257 t=     1.52 R=   7e+05
...

(Spin Version 6.5.1 -- 20 December 2019)
Warning: Search not completed
        + Partial Order Reduction

Full statespace search for:
        never claim             + (safety)
        assertion violations    + (if within scope of claim)
        acceptance   cycles     + (fairness disabled)
        invalid end states      - (disabled by never claim)

State-vector 244 byte, depth reached 9999999, errors: 0
  9853784 states, stored
 17826772 states, matched
 27680556 transitions (= stored+matched)
        0 atomic steps
hash conflicts:   2270082 (resolved)

Stats on memory usage (in Megabytes):
 2556.066       equivalent memory usage for states (stored*(State-vector + overhead))
 1515.731       actual memory usage for states (compression: 59.30%)
                state-vector as stored = 133 byte + 28 byte overhead
  128.000       memory used for hash table (-w24)
  534.058       memory used for DFS stack (-m10000000)
 2176.804       total actual memory usage



pan: elapsed time 14.7 seconds
pan: rate 671238.69 states/second
```

It means that the model is rather safe, because there are no states reached where the safety property is violated. So, no green light on the crossing routes.

---

## Liveness checks

Command:

```bash
spin -search -a -ltl liveness -O3 -w26 traffic-lights-9-simple.pml
```

Output:

```
ltl safety: [] ((((! (((p_light==green)) && (((es_light==green)) || ((sw_ne_light==green))))) && (! (((ns_light==green)) && (((sw_ne_light==green)) || ((es_light==green)))))) && (! (((es_light==green)) && ((((sw_ne_light==green)) || ((ns_light==green))) || ((p_light==green)))))) && (! (((sw_ne_light==green)) && ((((ns_light==green)) || ((es_light==green))) || ((p_light==green))))))
ltl liveness: ((([] ((! (((len(ns_sense)>0)) && ((ns_light==red)))) || (<> ((ns_light==green))))) && ([] ((! (((len(es_sense)>0)) && ((es_light==red)))) || (<> ((es_light==green)))))) && ([] ((! (((len(sw_ne_sense)>0)) && ((sw_ne_light==red)))) || (<> ((sw_ne_light==green)))))) && ([] ((! (((len(p_sense)>0)) && ((p_light==red)))) || (<> ((p_light==green)))))
ltl fairness: ((([] (<> (! (((ns_light==green)) && ((ns_sense==1)))))) && ([] (<> (! (((es_light==green)) && ((es_sense==1))))))) && ([] (<> (! (((sw_ne_light==green)) && ((sw_ne_sense==1))))))) && ([] (<> (! (((p_light==green)) && ((p_sense==1))))))
  the model contains 3 never claims: fairness, liveness, safety
  only one claim is used in a verification run
  choose which one with ./pan -a -N name (defaults to -N safety)
  or use e.g.: spin -search -ltl safety traffic-lights-9-simple.pml
pan: ltl formula liveness
Depth=     234 States=    1e+06 Transitions= 2.16e+06 Memory=   588.999 t=     0.84 R=   1e+06
...

(Spin Version 6.5.1 -- 20 December 2019)
Warning: Search not completed
        + Partial Order Reduction

Full statespace search for:
        never claim             + (liveness)
        assertion violations    + (if within scope of claim)
        acceptance   cycles     + (fairness disabled)
        invalid end states      - (disabled by never claim)

State-vector 244 byte, depth reached 840, errors: 0
 29707491 states, stored (5.94148e+07 visited)
 85250405 states, matched
1.4466516e+08 transitions (= visited+matched)
        0 atomic steps
hash conflicts:  16361128 (resolved)

Stats on memory usage (in Megabytes):
 7706.106       equivalent memory usage for states (stored*(State-vector + overhead))
 4533.168       actual memory usage for states (compression: 58.83%)
                state-vector as stored = 132 byte + 28 byte overhead
  512.000       memory used for hash table (-w26)
    0.534       memory used for DFS stack (-m10000)
 5045.640       total actual memory usage



pan: elapsed time 57.7 seconds
pan: rate 1029005.1 states/second
```

It means that when a car or pedestrian appears on a lane, they will eventually get an opportunity to cross the crossroads. So, no deadlock.

---

### Fairness checks

Command:

```bash
spin -search -a -ltl fairness -O3 -w26 traffic-lights-9-simple.pml
```

Output:

```
ltl safety: [] ((((! (((p_light==green)) && (((es_light==green)) || ((sw_ne_light==green))))) && (! (((ns_light==green)) && (((sw_ne_light==green)) || ((es_light==green)))))) && (! (((es_light==green)) && ((((sw_ne_light==green)) || ((ns_light==green))) || ((p_light==green)))))) && (! (((sw_ne_light==green)) && ((((ns_light==green)) || ((es_light==green))) || ((p_light==green))))))
ltl liveness: ((([] ((! (((len(ns_sense)>0)) && ((ns_light==red)))) || (<> ((ns_light==green))))) && ([] ((! (((len(es_sense)>0)) && ((es_light==red)))) || (<> ((es_light==green)))))) && ([] ((! (((len(sw_ne_sense)>0)) && ((sw_ne_light==red)))) || (<> ((sw_ne_light==green)))))) && ([] ((! (((len(p_sense)>0)) && ((p_light==red)))) || (<> ((p_light==green)))))
ltl fairness: ((([] (<> (! (((ns_light==green)) && ((ns_sense==1)))))) && ([] (<> (! (((es_light==green)) && ((es_sense==1))))))) && ([] (<> (! (((sw_ne_light==green)) && ((sw_ne_sense==1))))))) && ([] (<> (! (((p_light==green)) && ((p_sense==1))))))
  the model contains 3 never claims: fairness, liveness, safety
  only one claim is used in a verification run
  choose which one with ./pan -a -N name (defaults to -N safety)
  or use e.g.: spin -search -ltl safety traffic-lights-9-simple.pml
pan: ltl formula fairness
Depth= 1460921 States=    1e+06 Transitions= 2.95e+06 Memory=  5989.295 t=     1.25 R=   8e+05
...

(Spin Version 6.5.1 -- 20 December 2019)
Warning: Search not completed
        + Partial Order Reduction

Full statespace search for:
        never claim             + (fairness)
        assertion violations    + (if within scope of claim)
        acceptance   cycles     + (fairness disabled)
        invalid end states      - (disabled by never claim)

State-vector 204 byte, depth reached 30984143, errors: 0
 25372924 states, stored (2.58446e+07 visited)
 54664087 states, matched
 80508668 transitions (= visited+matched)
        0 atomic steps
hash conflicts:   5321494 (resolved)

Stats on memory usage (in Megabytes):
 5613.821       equivalent memory usage for states (stored*(State-vector + overhead))
 3522.874       actual memory usage for states (compression: 62.75%)
                state-vector as stored = 118 byte + 28 byte overhead
  512.000       memory used for hash table (-w26)
 5340.576       memory used for DFS stack (-m100000000)
    2.367       memory lost to fragmentation
 9373.084       total actual memory usage



pan: elapsed time 43.4 seconds
pan: rate 595085.91 states/second
```

It means that the traffic on each lane cannot be continuous. There will be a pause between the traffic flows on each lane.
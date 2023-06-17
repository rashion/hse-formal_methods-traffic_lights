# Code Description

## Definitions

Define the number of traffic lights and the size of the channels.

```promela
#define CHAN_SIZE 4
#define TRAFFIC_LIGHTS_NUM 4
```

Define the buffer variables (REQs) and the sensor channels.

```promela
bool sw_ne_buf, es_buf;
bool p_buf, ns_buf;

chan ns_sense = [CHAN_SIZE] of {bool};
chan es_sense = [CHAN_SIZE] of {bool};
chan sw_ne_sense = [CHAN_SIZE] of {bool};
chan p_sense = [CHAN_SIZE] of {bool};
```

Define the lock channels.

```promela
chan ns_lock = [1] of {bool};
chan es_lock = [1] of {bool};
chan sw_ne_lock = [1] of {bool};
chan p_lock = [1] of {bool};
```

Define the synchronization lock.

```promela
chan lock = [1] of {bool};
```

Define the array to ensure the fairness.

```promela
bool check_array[TRAFFIC_LIGHTS_NUM];
```

Define the traffic light types and the lights.

```promela
mtype = { red, green };
mtype ns_light, sw_ne_light, es_light, p_light;
```

## Fairness checker function

```promela
inline check(pointer) {
    // printf("pointer = %d\n", pointer);
    check_array[pointer] = true;
    bool result = true;
    int i;
    for (i : 0 .. (TRAFFIC_LIGHTS_NUM - 1)) {
        if
            :: check_array[i] == false -> 
                result = false;
                // printf("elem=%d\n", i);
            :: else -> skip;
        fi;
    };
    // printf("result = %d\n", result);
    if
        :: result == true ->
            for (i : 0 .. (TRAFFIC_LIGHTS_NUM - 1)) {
                check_array[i] = false;
            };
        :: else -> skip;
    fi;
}

## Light controller process example

```promela

```promela
active proctype NS_con() {
    printf("Start NS\n");
    int process_num = 0;
    do
        :: if
            :: (len(ns_sense) > 0) && (!check_array[process_num]) ->
                // (!sw_ne_lock && !es_lock) ->
                (len(sw_ne_lock) == 0 && len(es_lock) == 0) ->
                    {
                        lock?true;
                        // ns_lock = true;
                        ns_lock!true;
                        atomic 
                        {
                            ns_light = green;
                            printf("NS light green\n");
                        }
                        ns_sense?ns_buf;
                        atomic
                        {
                            ns_light = red;
                            printf("NS light red\n");
                        }
                        // ns_lock = false;
                        ns_lock?true;
                        lock!true;
                        ns_buf = false;
                        // ns_req?true;
                    }
        fi;
        check(process_num);
    od;
}
```

## Traffic generator process example

```promela
active proctype NS_gen() {
    printf("NS gen start\n");
    do
        :: atomic
        {
            ns_sense!true;
            printf("NS car generated\n");
        }
        // ns_req!true;
    od;
}
```

## Init process

```promela
init {
    ns_light = red;
    es_light = red;
    sw_ne_light = red;
    p_light = red;
    lock!true
}
```

## LTL properties

```promela
ltl safety {[]( !((p_light == green) && ((es_light == green) || (sw_ne_light == green))) &&
                !((ns_light == green) && ((sw_ne_light == green) || (es_light == green))) &&
                !((es_light == green) && ((sw_ne_light == green) || (ns_light == green) || (p_light == green))) &&
                !((sw_ne_light == green) && ((ns_light == green) || (es_light == green) || (p_light == green)))
        )};

ltl liveness {
            ([] ((len(ns_sense) > 0) && (ns_light == red) -> <> (ns_light == green))) &&
            ([] ((len(es_sense) > 0) && (es_light == red) -> <> (es_light == green))) &&
            ([] ((len(sw_ne_sense) > 0) && (sw_ne_light == red) -> <> (sw_ne_light == green))) &&
            ([] ((len(p_sense) > 0) && (p_light == red) -> <> (p_light == green)))
        };

ltl fairness {
        ([] <> !((ns_light == green) && (ns_sense[0] == true))) &&
        ([] <> !((es_light == green) && (es_sense[0] == true))) &&
        ([] <> !((sw_ne_light == green) && (sw_ne_sense[0] == true))) &&
        ([] <> !((p_light == green) && (p_sense[0] == true)))
    };
```
#define CHAN_SIZE 4
#define TRAFFIC_LIGHTS_NUM 4

bool sw_ne_buf, es_buf;
bool p_buf, ns_buf;

chan ns_sense = [CHAN_SIZE] of {bool};
chan es_sense = [CHAN_SIZE] of {bool};
chan sw_ne_sense = [CHAN_SIZE] of {bool};
chan p_sense = [CHAN_SIZE] of {bool};

// bool ns_lock = false, es_lock = false, p_lock = false, sw_ne_lock = false;

chan ns_lock = [1] of {bool};
chan es_lock = [1] of {bool};
chan sw_ne_lock = [1] of {bool};
chan p_lock = [1] of {bool};

// chan ns_req = [1] of {bool};
// chan es_req = [1] of {bool};
// chan sw_ne_req = [1] of {bool};
// chan p_req = [1] of {bool};

chan lock = [1] of {bool};

bool check_array[TRAFFIC_LIGHTS_NUM];

mtype = { red, green };
mtype ns_light, sw_ne_light, es_light, p_light;

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

active proctype ES_con() {
    printf("Start ES\n");
    int process_num = 1;
    do
        :: if
            :: (len(es_sense) > 0) && (!check_array[process_num]) ->
                // (!ns_lock && !sw_ne_lock && !p_lock) ->
                (len(ns_lock) == 0 && len(sw_ne_lock) == 0 && len(p_lock) == 0) ->
                    {
                        lock?true;
                        // es_lock = true;
                        es_lock!true;
                        atomic
                        {
                            es_light = green;
                            printf("ES light green\n");
                        }
                        es_sense?es_buf;
                        atomic
                        {
                            es_light = red;
                            printf("ES light red\n");
                        }
                        // es_lock = false;
                        es_lock?true;
                        lock!true;
                        es_buf = false;
                        // es_req?true;
                    }
        fi;
        check(process_num);
    od;
}

active proctype ES_gen() {
    printf("ES gen start\n");
    do
        :: atomic
        {
            es_sense!true;
            printf("ES car generated\n");
        }
        // es_req!true;
    od;
}

active proctype SW_NE_con() {
    printf("Start SW-NE\n");
    int process_num = 2;
    do
        :: if
            :: (len(sw_ne_sense) > 0) && (!check_array[process_num]) ->
                // (!ns_lock && !es_lock && !p_lock) ->
                (len(ns_lock) == 0 && len(es_lock) == 0 && len(p_lock) == 0) ->
                    {
                        lock?true;
                        // sw_ne_lock = true;
                        sw_ne_lock!true;
                        atomic
                        {
                            sw_ne_light = green;
                            printf("SW-NE light green\n");
                        }
                        sw_ne_sense?sw_ne_buf;
                        atomic
                        {
                            sw_ne_light = red;
                            printf("SW-NE light red\n");
                        }
                        // sw_ne_lock = false;
                        sw_ne_lock?true;
                        lock!true;
                        sw_ne_buf = false;
                        // sw_ne_req?true;
                    }
        fi;
        check(process_num);
    od;
}

active proctype SW_NE_gen() {
    printf("SW-NE gen start\n");
    do
         :: atomic
         {
             sw_ne_sense!true;
             printf("SW-NE car generated\n");
         }
        // sw_ne_req!true;
    od;
}

active proctype P_con() {
    printf("Start P\n");
    int process_num = 3;
    do
        :: if
            :: (len(p_sense) > 0) && (!check_array[process_num]) ->
                // (!sw_ne_lock && !es_lock) ->
                (len(sw_ne_lock) == 0) && (len(es_lock) == 0) ->
                    {
                        lock?true;
                        // p_lock = true;
                        p_lock!true;
                        atomic
                        {
                            p_light = green;
                            printf("P light green\n");
                        }
                        p_sense?p_buf;
                        atomic
                        {
                            p_light = red;
                            printf("P light red\n");
                        }
                        // p_lock = false;
                        p_lock?true;
                        lock!true;
                        p_buf = false;
                        // p_req?true;
                    }
        fi;
        check(process_num);
    od;
}

active proctype P_gen() {
    printf("P gen start\n");
    do
        :: atomic
        {
            p_sense!true;
            printf("P generated\n");
        }
        // p_req!true;
    od;
}

init {
    ns_light = red;
    es_light = red;
    sw_ne_light = red;
    p_light = red;
    lock!true
}

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
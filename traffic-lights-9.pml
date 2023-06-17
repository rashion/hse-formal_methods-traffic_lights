#define CHAN_SIZE 4
#define TRAFFIC_LIGHTS_NUM 6

#define n_sense_nempty (len(n_sense) != 0)
#define s_sense_nempty (len(s_sense) != 0)
#define sw_sense_nempty (len(sw_sense) != 0)
#define ne_sense_nempty (len(ne_sense) != 0)
#define es_sense_nempty (len(es_sense) != 0)
#define p_sense_nempty (len(p_sense) != 0)
// #define pn_sense_nempty (len(pn_sense) != 0)
// #define ps_sense_nempty (len(ps_sense) != 0)

bool n_buf, s_buf, sw_buf, ne_buf, es_buf;
bool p_buf;
// bool pn_buf, ps_buf;

chan n_sense = [CHAN_SIZE] of {bool};
chan s_sense = [CHAN_SIZE] of {bool};
chan sw_sense = [CHAN_SIZE] of {bool};
chan ne_sense = [CHAN_SIZE] of {bool};
chan es_sense = [CHAN_SIZE] of {bool};
chan p_sense = [CHAN_SIZE] of {bool};
// chan pn_sense = [CHAN_SIZE] of {bool};
// chan ps_sense = [CHAN_SIZE] of {bool};

bool sw_lock = false, es_lock = false, ne_lock = false, s_lock = false;
bool n_lock = false, p_lock = false;

bool check_array[TRAFFIC_LIGHTS_NUM];

mtype = { red, green };
mtype n_light, s_light, sw_light = red, ne_light = red, es_light = red, p_light = red; // pn_light = red, ps_light = red;

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

active proctype N_con() {
    printf("Start N\n");
    int process_num = 0;
    do
       :: if
             :: len(n_sense) > 0 && !check_array[process_num] -> 
                (!es_lock && !ne_lock) ->
                {
                    n_lock = true;
                    atomic 
                    {
                        n_light = green;
                        printf("N light green\n");
                    }
                    n_sense?n_buf;
                    n_lock = false;
                    atomic
                    {
                        n_light = red;
                        printf("N light red\n");
                    }
                }
            :: else -> skip;
          fi; 
          check(process_num);
    od;
}

active proctype N_gen() {
    printf("N gen start\n");
    do
         :: atomic
         {
             n_sense!true;
             printf("N car generated\n");
         }
    od;
}

active proctype ES_con() {
    printf("Start E\n");
    int process_num = 1;
    do
    :: if
        :: len(es_sense) > 0 && !check_array[process_num] ->
            (!n_lock && !s_lock && !sw_lock && !ne_lock && !p_lock) ->
            {
                es_lock = true;
                atomic
                {
                    es_light = green;
                    printf("E light green\n");
                }
                es_sense?es_buf;
                es_lock = false;
                atomic
                {
                    es_light = red;
                    printf("E light red\n");
                }
            }
        :: else -> skip;
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
    od;
}

active proctype S_con() {
    printf("Start S\n");
    int process_num = 2;
    do
       :: if
             :: len(s_sense) > 0 && !check_array[process_num] ->
                (!sw_lock && !es_lock) ->
                {
                    s_lock = true;
                    atomic
                    {
                        s_light = green;
                        printf("S light green\n");
                    }
                    s_sense?s_buf;
                    s_lock = false;
                    atomic
                    {
                        s_light = red;
                        printf("S light red\n");
                    }
                }
            :: else -> skip;
          fi; 
          check(process_num);
    od;
}

active proctype S_gen() {
    printf("S gen start\n");
    do
         :: atomic
         {
             s_sense!true;
             printf("S car generated\n");
         }
    od;
}

active proctype PN_con() {
    printf("Start P\n");
    int process_num = 3;
    do
        :: if
            :: len(p_sense) > 0 && !check_array[process_num] ->
                (!ne_lock && !es_lock) ->
                {
                    p_lock = true;
                    atomic
                    {
                        p_light = green;
                        printf("P light green\n");
                    }
                    p_sense?p_buf;
                    p_lock = false;
                    atomic
                    {
                        p_light = red;
                        printf("P light red\n");
                    }
                }
            :: else -> skip;
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
    od;
}

// active proctype PS_con() {
//     printf("Start PN\n");
//     int process_num = 4;
//     do
//         :: if
//             :: len(ps_sense) > 0 && !check_array[process_num] ->
//                 (!ne_lock && !es_lock) ->
//                 {
//                     p_lock = true;
//                     atomic
//                     {
//                         ps_light = green;
//                         printf("PS light green\n");
//                     }
//                     ps_sense?ps_buf;
//                     p_lock = false;
//                     atomic
//                     {
//                         ps_light = red;
//                         printf("PS light red\n");
//                     }
//                 }
//             :: else -> skip;
//         fi;
//         check(process_num);
//     od;
// }

// active proctype PS_gen() {
//     printf("PS gen start\n");
//     do
//          :: atomic
//          {
//              ps_sense!true;
//              printf("PS generated\n");
//          }
//     od;
// }

active proctype SW_con() {
    printf("Start SW\n");
    int process_num = 4;
    do
        :: if
            :: len(sw_sense) > 0 && !check_array[process_num] ->
                (!s_lock && !es_lock) ->
                {
                    sw_lock = true;
                    atomic
                    {
                        sw_light = green;
                        printf("SW light green\n");
                    }
                    sw_sense?sw_buf;
                    sw_lock = false;
                    atomic
                    {
                        sw_light = red;
                        printf("SW light red\n");
                    }
                }
            :: else -> skip;
        fi;
        check(process_num);
    od;
}

active proctype SW_gen() {
    printf("SW gen start\n");
    do
         :: atomic
         {
             sw_sense!true;
             printf("SW car generated\n");
         }
    od;
}

active proctype NE_con() {
    printf("Start NE\n");
    int process_num = 5;
    do
        :: if
            :: len(ne_sense) > 0 && !check_array[process_num] ->
                (!n_lock && !es_lock && !p_lock) ->
                {
                    ne_lock = true;
                    atomic
                    {
                        ne_light = green;
                        printf("NE light green\n");
                    }
                    ne_sense?ne_buf;
                    ne_lock = false;
                    atomic
                    {
                        ne_light = red;
                        printf("NE light red\n");
                    }
                }
            :: else -> skip;
        fi;
        check(process_num);
    od;
}

active proctype NE_gen() {
    printf("NE gen start\n");
    do
         :: atomic
         {
             ne_sense!true;
             printf("NE car generated\n");
         }
    od;
}

ltl s1 {[] !((s_light == green) && (sw_light == green) && (es_light == green))};

// ltl s2 {[] !((e_light == green) && (s_light == green) && (n_light == green) && (p_light == green))};

// ltl s3 {[] !((e_light == green) && (p_light == green))};

// ltl l1 {(
//             ([]<> !((n_light == green) && n_sense_nempty))
//         ) -> (
//             ([] ((n_sense_nempty && (n_light == red)) -> (<> (n_light == green))))
//         )};

// ltl l2 {(
//             ([]<> !((e_light == green) && e_sense_nempty))
//         ) -> (
//             ([] ((e_sense_nempty && (e_light == red)) -> (<> (e_light == green))))
//         )};

// ltl l3 {(
//             ([]<> !((s_light == green) && s_sense_nempty))
//         ) -> (
//             ([] ((s_sense_nempty && (s_light == red)) -> (<> (s_light == green))))
//         )};

// ltl l4 {(
//             ([]<> !((p_light == green) && p_sense_nempty))
//         ) -> (
//             ([] ((p_sense_nempty && (p_light == red)) -> (<> (p_light == green))))
//         )};
#define CHAN_SIZE 4
// #define TRAFFIC_LIGHTS_NUM 3
#define n_sense_nempty (len(n_sense) != 0)
#define e_sense_nempty (len(e_sense) != 0)
#define s_sense_nempty (len(s_sense) != 0)
#define p_sense_nempty (len(p_sense) != 0)

bool n_buf, s_buf, e_buf, p_buf;
chan n_sense = [CHAN_SIZE] of {bool};
chan s_sense = [CHAN_SIZE] of {bool};
chan e_sense = [CHAN_SIZE] of {bool};
chan p_sense = [CHAN_SIZE] of {bool};
bool ns_lock = false, we_lock = false;

// bool fair_array[TRAFFIC_LIGHTS_NUM];


mtype = { red, green };
mtype n_light, s_light, e_light, p_light = red;

// inline fair_check(pointer) {
//     printf("pointer = %d", pointer);
//     fair_array[pointer] = true;
//     bool result = true;
//     int i;
//     for (i : 0 .. (TRAFFIC_LIGHTS_NUM - 1)) {
//         if
//             :: fair_array[i] == false -> printf("elem=%d", i); result = false;
//             :: else -> skip;
//         fi;
//     };
//     printf("result = %d", result);
//     if
//         :: result == true ->
//             for (i : 0 .. (TRAFFIC_LIGHTS_NUM - 1)) {
//                 fair_array[i] = false;
//         };
//         :: else -> skip;
//     fi;
// }

active proctype N() {
    printf("Start N\n");
    do
       :: if
             :: len(n_sense) > 0 -> (!we_lock) -> ns_lock = true; n_light = green;
                printf("N light green\n"); n_sense?n_buf; n_light = red; ns_lock = false; printf("N light red\n");

          fi; // fair_check(0);
    od;
}

active proctype N_gen() {
    printf("N gen start\n");
    do
         :: n_sense!true; printf("N car generated\n");
    od;
}

active proctype E() {
    do
    :: if
         :: len(e_sense) > 0 -> (!ns_lock) -> we_lock = true; e_light = green;
            printf("E light green\n"); e_sense?e_buf; e_light = red; we_lock = false; printf("E light red\n");
    fi; // fair_check(1);
    od;
}

active proctype E_gen() {
    printf("E gen start\n");
    do
         :: e_sense!true; printf("E car generated\n");
    od;
}

active proctype P() {
    do
    :: if
         :: len(p_sense) > 0 -> (!we_lock) -> we_lock = true; p_light = green;
            printf("P light green\n"); p_sense?p_buf; p_light = red; we_lock = false; printf("P light red\n");
    fi; // fair_check(1);
    od;
}

active proctype P_gen() {
    printf("P gen start\n");
    do
         :: p_sense!true; printf("P generated\n");
    od;
}

active proctype S() {
    printf("Start S\n");
    do
       :: if
             :: len(s_sense) > 0 -> (!we_lock) -> ns_lock = true; s_light = green;
                printf("S light green\n"); s_sense?s_buf; s_light = red; ns_lock = false; printf("S light red\n");

          fi; // fair_check(0);
    od;
}

active proctype S_gen() {
    printf("S gen start\n");
    do
         :: s_sense!true; printf("S car generated\n");
    od;
}

// active proctype init() {
//     run N();
//     run N_gen();
//     run E();
//     run E_gen();
//     run P();
//     run P_gen();
//     run S();
//     run S_gen();
// }


ltl s1 {[] !((n_light == green) && (e_light == green))};

ltl s2 {[] !((e_light == green) && (s_light == green) && (n_light == green) && (p_light == green))};

ltl s3 {[] !((s_light == green) && (e_light == green))};

ltl l1 {(
            ([]<> !((n_light == green) && n_sense_nempty))
        ) -> (
            ([] ((n_sense_nempty && (n_light == red)) -> (<> (n_light == green))))
        )};

ltl l2 {(
            ([]<> !((e_light == green) && e_sense_nempty))
        ) -> (
            ([] ((e_sense_nempty && (e_light == red)) -> (<> (e_light == green))))
        )};

ltl l3 {(
            ([]<> !((s_light == green) && s_sense_nempty))
        ) -> (
            ([] ((s_sense_nempty && (s_light == red)) -> (<> (s_light == green))))
        )};

ltl l4 {(
            ([]<> !((p_light == green) && p_sense_nempty))
        ) -> (
            ([] ((p_sense_nempty && (p_light == red)) -> (<> (p_light == green))))
        )};
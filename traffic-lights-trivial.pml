#define CHAN_SIZE 4
#define TRAFFIC_LIGHTS_NUM 4
#define n_sense_nempty (len(n_sense) != 0)
#define e_sense_nempty (len(e_sense) != 0)
#define s_sense_nempty (len(s_sense) != 0)
#define p_sense_nempty (len(p_sense) != 0)

bool n_buf, s_buf, e_buf, p_buf;
chan n_sense = [CHAN_SIZE] of {bool};
chan s_sense = [CHAN_SIZE] of {bool};
chan e_sense = [CHAN_SIZE] of {bool};
chan p_sense = [CHAN_SIZE] of {bool};
bool ns_lock = false, we_lock = false, p_lock = false;

bool check_array[TRAFFIC_LIGHTS_NUM];


mtype = { red, green };
mtype n_light, s_light, e_light = red, p_light = red;

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
                (!we_lock) ->
                {
                    ns_lock = true;
                    atomic 
                    {
                        n_light = green;
                        printf("N light green\n");
                    }
                    n_sense?n_buf;
                    ns_lock = false;
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

active proctype E_con() {
    printf("Start E\n");
    int process_num = 1;
    do
    :: if
        :: len(e_sense) > 0 && !check_array[process_num] ->
            (!ns_lock && !p_lock) ->
            {
                we_lock = true;
                atomic
                {
                    e_light = green;
                    printf("E light green\n");
                }
                e_sense?e_buf;
                we_lock = false;
                atomic
                {
                    e_light = red;
                    printf("E light red\n");
                }
            }
        :: else -> skip;
    fi;
    check(process_num);
    od;
}

active proctype E_gen() {
    printf("E gen start\n");
    do
         :: atomic
         {
             e_sense!true;
             printf("E car generated\n");
         }
    od;
}

active proctype S_con() {
    printf("Start S\n");
    int process_num = 2;
    do
       :: if
             :: len(s_sense) > 0 && !check_array[process_num] ->
                (!we_lock) ->
                {
                    ns_lock = true;
                    atomic
                    {
                        s_light = green;
                        printf("S light green\n");
                    }
                    s_sense?s_buf;
                    ns_lock = false;
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

active proctype P_con() {
    printf("Start P\n");
    int process_num = 3;
    do
        :: if
            :: len(p_sense) > 0 && !check_array[process_num] ->
                (!we_lock) ->
                {
                    we_lock = true;
                    atomic
                    {
                        p_light = green;
                        printf("P light green\n");
                    }
                    p_sense?p_buf;
                    we_lock = false;
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

ltl s1 {[] !((n_light == green) && (s_light == green) && (e_light == green))};

ltl s2 {[] !((e_light == green) && (s_light == green) && (n_light == green) && (p_light == green))};

ltl s3 {[] !((e_light == green) && (p_light == green))};

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
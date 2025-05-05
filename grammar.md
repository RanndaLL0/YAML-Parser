---------YAML PARSER----------

S -> OZ | MU | VA
Z -> VX | NM | STRING | NUMBER | BOOLEAN | NULL | SIGN
M -> LS | LV | VG

X -> NS
O -> VT
U -> OZ
G -> TZ
A -> TV

V -> STRING | NUMBER | BOOLEAN | NULL | SIGN
T -> COLON
N -> NEWLINE
L -> DASH

---------CALC PARSER----------

S -> SZ | SW | AY | AX | NU | DIGITOS | ON | EQ
A -> AY | AX |NU | DIGITOS | ON | EQ
B -> NU | DIGITOS | ON | EQ
E -> JS | JA | JB
Z -> LA | LN
W -> OA | ON
Y -> FB | FN
X -> PB | PN
U -> HA | HB | HS
O -> SUB
L -> SUM
F -> MULT
P -> DIV
H -> EXP
N -> DIGITOS
J -> PARENT_LEFT
Q -> PARENT_RIGHT
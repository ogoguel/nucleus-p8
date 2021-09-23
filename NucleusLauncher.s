  org $5000 
    
OPEN    = #$C8
READ = #$CA
MLI = #$BF00
DATA_BUFFER_LENGTH = #512   ; block size
CURRENT_PATH = #$0280
original

    MX %11

    STA $C000
    STA $C00C 

    JSR $FE89
    JSR $FE93
    JSR $FB2F
    JSR $FC58

; check 2GS
    SEC
    JSR $FE1F
    BCC Hardware2GS

    LDY GS_REQUIRED-#$3000
]loop
    LDA GS_REQUIRED-#$3000,y
    STA $400,Y
    DEY
    BNE ]loop
]infinite
    BRA ]infinite

GS_REQUIRED STR "NUCLEUS REQUIRED A 2GS!"

Hardware2GS

]vbl
    LDA $C019
    BMI ]vbl
]vbl
    LDA $C019
    BPL ]vbl

    STZ $C034
    LDA #$F0
    STA $C022

    CLC
    XCE
    REP #$30
    LDA #himem-original
    LDX #$2000
    LDY #original
    MVN 0,0
    JMP STArt

STArt

    MX %11

    SEC
    XCE
    SEP #$30

; Fix prefix (https://retrocomputing.STAckexchange.com/questions/17922/apple-ii-prodos-zero-length-prefix-AND-mli-calls/17979)
 
]loop
    JSR    MLI
op_c7
    DFB  $c7
    DW  c7_parms
     BCC no_error_c7
     JMP open_error
no_error_c7
    LDX    $300
    BNE    done_prefix
    LDA    $bf30
    STA    c5_parms+1
    JSR    MLI
    DFB  $c5
    DW  c5_parms
    BCC no_error_c5
    JMP open_error
no_error_c5
    LDA    $301
    AND    #$0f
    TAX
    INX
    STX    $300
    LDA    #$2f
    STA    $301
    DEC    op_c7
    BNE    ]loop

c7_parms
    DFB  1
   DW  $300

c5_parms
    DFB 2
    DFB  0
    DW $301

done_prefix
    LDY CURRENT_PATH
]loop
    LDA CURRENT_PATH,Y
    STA full_path,Y
    DEY
    BPL ]loop
    LDY CURRENT_PATH
]loop
    DEY
    LDA full_path,Y
    CMP #'.'
    BNE ]loop
    INY
    LDA #'D'
    STA full_path,y
    iny
    LDA #'A'
    STA full_path,Y
    iny
    LDA #'T'
    STA full_path,Y
    LDA #'A'
    INY
    STA full_path,Y
    sty full_path
    LDA #>data_buffer
    CLC
    ADC #DATA_BUFFER_LENGTH/256+1
    STA open_himem+1

    JSR MLI
    DFB OPEN
    DW open_params
    BCS open_error

    LDA open_ref
    STA read_ref

    CLC
    XCE
    REP #$30
    MX %00
    LDX #0
]loop
    PHX
    TXA
    asl
    asl
    TAX 
    LDA files,x
    BEQ end_load
    TAY
    LDA files+2,x
    JSR load

    PLX
    cpx #0
    BNE not_first
    
    PHX
    SEP #$30
 
    JSR #$0A00
 
]vbl
    LDA $C019
    BMI ]vbl
]vbl
    LDA $C019
    BPL ]vbl

    LDA #$C1
    STA $C029
 
    JSR fade_in
 
    SEP #$30
    MX %11

    LDA #$1E
    STA $C035

    CLC
    XCE
    REP #$30
    PLX
    
not_first
    INX
    BRA ]loop
end_load

    ; patch code to bypass protection

    INC $3F4
    
    LDA #$6B18
    STAL $E10048

    LDA #$0966
    STA $0802
    LDA #$0BD0
    STA $0987 
    LDA #$96AB
    STA $9605
    LDA #$07F0
    STA $96CC
    
    SEC
    XCE
    SEP #$30
    MX %11  
    JMP #$1000

open_error
read_error
    CLC
    XCE
    SEP #$30
    LDA #$41
    STA $C029
    REP #$30
    PEA #$DEAD
    PEA $0
    PEA msg_read_error
    LDX #$1503
    JSL $E10000
msg_read_error STR "Cannot find NUCLEUS.DATA : "  

fade_in
    MX %11
    SEP #$30
]loop
]vbl
    LDA $C019
    BMI ]vbl
]vbl
    LDA $C019
    BPL ]vbl
    REP #$20
    LDAL $E19E1E
    CLC
    ADC #$0111
    STAL $E19E1E
    SEP #$20
    CMP #$FF
    BNE ]loop
    RTS

load    ; A = NB, Y=mem
     MX %11
    SEP #$30
   
    STA mem_dst+1
    XBA
    STA MVN_patch+1

    REP #$30
     MX %00
]loop
    PHY
    SEC
    XCE
    SEP #$30
     MX %11
    JSR MLI
    DFB READ
    DW read_params
    BCS read_error
  
    CLC
    XCE
    REP #$30
    MX %00
    LDA #DATA_BUFFER_LENGTH-1
    LDX #data_buffer
    LDY mem_dst

    phb
MVN_patch
    MVN 0,0
    plb
    LDA mem_dst
    CLC
    ADC #DATA_BUFFER_LENGTH
    STA mem_dst

    PLY
    DEY
    BNE ]loop
    RTS
   
mem_dst DW 0


files 
    DW #5 ; #0
    DW #$000A
    DW #128 ; #0
    DW #$0300
    DW #128 ; #0
    DW #$0400
    DW #2 ; #0
    DW #$0803
    DW #14 ; #0
    DW #$0820
    DW #8 ; #0
    DW #$0840
    DW #7 ; #0
    DW #$0860
    DW #2 ; #0
    DW #$0880
    DW #32 ; #0
    DW #$0c00
    DW #4 ; #0
    DW #$0810
    DW #11 ; #0
    DW #$0c80
    DW #17 ; #0
    DW #$0900
    DW #11 ; #0
    DW #$0600
    DW #19 ; #0
    DW #$0010
    DW #2 ; #0
    DW #$0040
    DW #2 ; #0
    DW #$0940
    DW #11 ; #0
    DW #$0060
    DW #0 ; END
    
read_params DB 4
read_ref DB 0
         DW data_buffer
         DW DATA_BUFFER_LENGTH
read_count DW 0      

open_params DFB 3
      DW full_path
   
open_himem  DW #0
open_ref      DB 0

full_path DS 128

data_buffer
     DB 0
himem
    BRK 0

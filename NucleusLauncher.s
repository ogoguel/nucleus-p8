  org $5000 
    
OPEN    = #$C8
READ = #$CA
MLI = #$BF00
DATA_BUFFER_LENGTH = #512   ; block size
CURRENT_PATH = #$0280
original

    mx %11

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

    clc
    xce
    rep #$30
    LDA #himem-original
    ldx #$2000
    ldy #original
    mvn 0,0
    jmp start

start

    mx %11

  
    clc
    xce
    sep #$30

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
    sta full_path,y
    iny
    lda #'A'
    sta full_path,Y
    iny
    lda #'T'
    sta full_path,Y
    LDA #'A'
    INY
    sta full_path,Y
    sty full_path
    LDA #>data_buffer
    CLC
    ADC #DATA_BUFFER_LENGTH/256+1
    STA open_himem+1

    JSR MLI
    DFB OPEN
    DW open_params
    BNE open_error

    LDA open_ref
    STA read_ref

    clc
    xce
    rep #$30
    mx %00
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

    plx
    cpx #0
    bne not_first
    
    phx
    sep #$30
 
    jsr #$0A00
 
]vbl
    LDA $C019
    BMI ]vbl
]vbl
    LDA $C019
    BPL ]vbl

    lda #$C1
    sta $C029
 
    jsr fade_in
 
    sep #$30
    mx %11

    LDA #$1E
    STA $C035

    clc
    xce
    rep #$30
    plx
    
not_first
    inx
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
    
    sec
    xce
    sep #$30
    mx %11  
    JMP #$1000

open_error
read_error
    clc
    xce
    sep #$30
    lda #$41
    sta $C029
    rep #$30
    PEA #$DEAD
    PEA $0
    PEA msg_read_error
    LDX #$1503
    JSL $E10000
msg_read_error STR "Cannot find NUCLEUS.DATA : "  


    


fade_in
    mx %11
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
    clc
    ADC #$0111
    STAL $E19E1E
    SEP #$20
    CMP #$FF
    BNE ]loop
    RTS

load    ; A = NB, Y=mem
     mx %11
    SEP #$30
   
    STA mem_dst+1
    XBA
    STA mvn_patch+1

    REP #$30
     mx %00
]loop
    PHY
    sec
    xce
    sep #$30
     mx %11
    JSR MLI
    DFB READ
    DW read_params
    BNE read_error
  
    clc
    xce
    rep #$30
    mx %00
    LDA #DATA_BUFFER_LENGTH-1
    LDX #data_buffer
    LDY mem_dst

    phb
mvn_patch
    MVN 0,0
    plb
    LDA mem_dst
    clc
    ADC #DATA_BUFFER_LENGTH
    sta mem_dst

    PLY
    DEY
    bne ]loop
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

;path STR "/NUCLEUSP8/NUCLEUS.DATA"

    
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

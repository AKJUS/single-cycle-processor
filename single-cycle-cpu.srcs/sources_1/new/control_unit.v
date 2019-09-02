`timescale 1ns / 1ps
`include "instruction_head.v"

/* Module: Control Unit
 */

module control_unit(
           input wire[5:0] opcode,
           input wire[4:0] sa,
           input wire[5:0] func,
           input wire      zero, // For instruction BEQ, determining the result of rs-rt

           output wire[`ALU_OP_LENGTH  - 1:0] alu_op,
           output wire                        reg_dst,
           output wire                        reg_write,
           output wire                        alu_src,
           output wire                        mem_write,
           output wire[`REG_SRC_LENGTH - 1:0] reg_src,
           output wire[`EXT_OP_LENGTH  - 1:0] ext_op,
           output wire[`NPC_OP_LENGTH  - 1:0] npc_op
       );

wire type_r, lui, addiu, add, subu, lw, sw, beq, j;

// Whether instruction is R-Type
assign type_r    = (opcode == `INST_R_TYPE)       ? 1 : 0;
// R-Type instructions
assign add       = (type_r && func == `FUNC_ADD)  ? 1 : 0;
assign subu      = (type_r && func == `FUNC_SUBU) ? 1 : 0;

// I-Type Instructions
assign lui       = (opcode == `INST_LUI)          ? 1 : 0;
assign addiu     = (opcode == `INST_ADDIU)        ? 1 : 0;
assign lw        = (opcode == `INST_LW)           ? 1 : 0;
assign sw        = (opcode == `INST_SW)           ? 1 : 0;
assign beq       = (opcode == `INST_BEQ)          ? 1 : 0;

// J-Type Instructions
assign j         = (opcode == `INST_J)            ? 1 : 0;

// Determine control signals
assign alu_op    = (add || addiu || lw || sw) ? `ALU_OP_ADD :
       (subu || beq) ? `ALU_OP_SUB : `ALU_OP_DEFAULT;
assign reg_dst   = (add || subu) ? 1 : 0;
assign reg_write = (lui || type_r || add || subu || addiu || lw) ? 1 : 0;
assign alu_src   = (addiu || lw || sw) ? 1 : 0;
assign mem_write = (sw) ? 1 : 0;
assign reg_src   = (lui) ? `REG_SRC_IMM :
       (addiu || add || subu) ? `REG_SRC_ALU :
       (lw) ? `REG_SRC_MEM : `REG_SRC_DEFAULT;
assign ext_op    = (lui) ? `EXT_OP_SFT16 :
       (addiu) ? `EXT_OP_SIGNED :
       (lw || sw) ? `EXT_OP_UNSIGNED :
       `EXT_OP_DEFAULT;
assign npc_op    = (lui || addiu || add || subu || lw || sw) ? `NPC_OP_NEXT :
       (beq && !zero) ? `NPC_OP_NEXT :
       (beq && zero) ? `NPC_OP_OFFSET :
       (j) ? `NPC_OP_JUMP : `NPC_OP_DEFAULT;
endmodule

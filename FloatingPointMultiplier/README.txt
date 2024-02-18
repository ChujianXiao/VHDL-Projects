--FLOATING POINT MULTIPLIER--
A simple 16 bit floating point multiplier. The number format is similar to that of IEEE-754, however in this implementation there are 7 bits for the Exponent
and 8 bits for the Mantissa. The top level entity is floatingPointMultiplier.vhd.

Inputs:
i_clock: The system clock.
i_globalReset: The global reset.
i_inA,i_inB: The 16 bit inputs of the multiplier.

Outputs:
o_overflow: Detects overflow. In this case it detects if the exponent of the product exceeds 7 bits or is less than 0.
o_output: The output for the product.
o_partialProduct: The product of the mantissa multiplication for debugging purposes.
o_state: The state of the control path for debugging purposes 

To use the project:
Use tools such as Modelsim to create a simulation or Quartus to synthesize the project and upload it to an FPGA.
The top level entity should be set as floatingPointMultiplier.vhd.
Introduction:

Lab 1 displays oscilloscope graphics using VGA built from the ground-up. Everything from the timing signals, pixel coordinates, and color-mapping to the drawing of the grid lines and waveform channels were made from scratch. User inputs can adjust the trigger indicators and enable and disable the waveform channels using the buttons and switches on the FPGA board. The final product outputs that VGA signal over the board's HDMI port to an external display.

Design/Implementation:

    Lab1 interfaces with the board's I/O and instantiates the numeric steppers and video subsystem, connecting intermediate control signals.

        Inputs:
                clk - system clock
                reset_n - active-low reset
                btn - pushbuttons
                sw - channel enable/disable switches

        Outputs:
                tmds & tmdsb - HDMI output signals
                led - show when switches are on

        Buttons increment/decrement trigger values using numeric steppers. Switches determine whether channels are enabled.

    Numeric Stepper stores and adjusts numeric values based on button activity.

        Inputs:
                clk
                reset_n
                up - button to increment value
                down - button to decrement value
                en - enable (high/low signal)

        Output:
                q - stored value

        Rising clock edge detects signal on up/down and adjusts Q accordingly, adding or subtracting based on a defined delta value and keeping Q between defined min and max values.

    Video connects different clocks with IP-provided clocking wizard as well as broader VGA timing, color handling, and digital signal encoding for HDMI output.

        Inputs:
                clk
                reset_n
                trigger - handles display of triangles at edges of screen to represent trigger values
                ch1 - waveform 1 signal
                ch2 - waveform 2 signal

        Outputs:
                tmds & tmdsb
                position - pixel coordinates in row/column form

    VGA Signal Generator handles the specific VGA timing and processes the pixel coordinates from Video.

        Outputs:
                hsync - horizontal sync signal part of VGA scanning scheme, indicates when position is a usable part of the screen
                vsync - vertical sync signal part of VGA scanning scheme, functions identically to hsync
                blank - indicates whether current position is in usable screen area (high/low signal)
                row - y position
                column - x position

        Implements horizontal/vertical counters to track 640x480 screen area

    Color Mapper uses trigger values and state of waveforms to decide drawn colors on the screen

        Inputs:
                pixel - (row, column, blank)
                trigger
                ch1
                ch2
        Output:
                RGB Color string

        Handles the grid lines, trigger markers, and channel waveforms.

    DVID Encoder takes in video data and combines VGA timing and color data into HDMI signal to allow video output on FPGA board.

Test/Debug:
            Use of provided Instructor_tb verified functionality of VGA timing and counters.

            vga log testbench simulated VGA signal and outputted data to .txt file which was rendered on the online VGA simulator to show basic functionality with waveforms and gridlines

            After basic functionality of the VGA signal was established, I performed hardware testing, on the FPGA board, verifying proper I/O functionality and display response. 

            Initially, the hoirzontal and vertical counters were limited to 640 and 480 as I misunderstood their purpose and forgot to include the extra front porch/sync/back porch data which caused incorrect sync behavior. To fix this, the hoirzontal and vertical counter maximums were adjusted to 799 and 524 respectively to accomodate the requisite data signals.

            Early simulations stopped before showing the counter's rollover behavior, making it seem like the counters were not wrapping correctly. The testbench simulation time was increased so the counters could hit their max values and demonstrate the rollover behavior and vertical increment.

            The diagonal channel traces extended beyond the oscilloscope grid and into the unused screen area. To fix this, the channel activation logic was gated with row and column ranges that corresponded to the usable screen space.

            Horizontal hash marks showed up lower than the expected midline of the grid. To fix this, the center_row constant in Color Mapper was adjusted to the correct value between grid_start_row and grid_stop_row.

            Although the switches were wired to ch1.en and ch2.en, the channels always remained on regardless of the switch state. Updating the logic in Color Mapper to take both the enable and activate channel signals corrected that behavior ensuring the switches changed the waveform visibility.

            I ran into a lot of synthesis issues because my IP clocking wizard was improperly configured to only have one output clock and use the normal reset signal instead of the active-low reset_n signal. Going into the IP configurator made fixing the clocking wizard easy but I was unable to replicate the issue.

            ![alt text](https://github.com/drcolephd/ece383_wksp/blob/main/Lab1-demo/screenshots/blankflip.png)
            ![alt text](https://github.com/drcolephd/ece383_wksp/blob/main/Lab1-demo/screenshots/horizontal_rollup.png)
            ![alt text](https://github.com/drcolephd/ece383_wksp/blob/main/Lab1-demo/screenshots/rowflip.png)

Results:
            VGA Timing/Pixel coordinates: Completed 1/22/2026. Created hsync/vsync/blank signals and horizontal/vertical counters for rows and columns. Waveform screenshots submitted

            VGA Image Output: Completed 1/27/2026. Output oscilloscope grid and hashmarks. Demo'd to instructor

            Channel enable & Full display output: Completed 1/29/2026. Output waveforms to oscilloscope grid. Demo'd to instructor.

            Trigger and Waveform control: Completed 1/29/2026. Manipulate waveforms with switches and triggers with buttons. Video submitted to instructor.

Conclusion:
            This lab shined a light on how seemingly complicated digital systems such as the oscilloscopes we use in our electronics labs are fundamentally built on smaller modules that we are capable of creating ourselves. The tolerances in the VGA timing are tight, demanding precision and coordination between sync signals and horizontal and vertical scanning. Hardware debugging was a lengthy process due to the time required to synthesize and implement the project files, so software testbenches proved invaluable in assessing device behavior in a timely manner. Future iterations of this lab could benefit from some conversations on debouncing and how to clean inputs coming into a system.
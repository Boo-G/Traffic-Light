module full_traffic_light(
//traffic_light_controller
input clk_27,
input reset,
input de_bug,
input left_turn_request,
input [1:0]push_button,

output northbound_green, northbound_amber, northbound_red,
output southbound_green, southbound_amber, southbound_red,
output [1:0] southbound_arrow,
output eastbound_green, eastbound_amber, eastbound_red,
output westbound_green, westbound_amber, westbound_red,
output [4:0] NBnd_D, SBnd_D, EBnd_D, WBnd_D, 
//output [4:0] WBnd_FD, NBnd_FD, SBnd_FD, EBnd_FD,
//output NBnd_W,
//output SBnd_W,
//output EBnd_W,
//output WBnd_W,
output [6:1] northbound, southbound, eastbound, westbound
//output walk_request
);

reg [4:0] WBnd_FD, NBnd_FD, SBnd_FD, EBnd_FD;
reg NBnd_W;
reg SBnd_W;
reg EBnd_W;
reg WBnd_W;




always @ (*)
	begin
	northbound = {NBnd_W,NBnd_FD};
	southbound = {SBnd_W,SBnd_FD};
	eastbound = {EBnd_W,EBnd_FD};
	westbound = {WBnd_W,WBnd_FD};
	end
	
	
wire clk;
// lab 2 exam
wire entering_state_2s, state_2s, state_2s_d, staying_in_state_2s;


wire entering_state_1w, entering_state_1fd, entering_state_1d, entering_state_1, entering_state_2, entering_state_3, entering_state_4a, entering_state_4w, entering_state_4fd, entering_state_4d, entering_state_4, entering_state_5, entering_state_6;

wire state_1w, state_1fd, state_1d, state_1, state_2, state_3, state_4a, state_4w, state_4fd, state_4d, state_4, state_5, state_6;

wire state_1w_d, state_1fd_d, state_1d_d, state_1_d, state_2_d, state_3_d, state_4a_d, state_4w_d, state_4fd_d, state_4d_d, state_4_d, state_5_d, state_6_d;

wire staying_in_state_1w, staying_in_state_1fd, staying_in_state_1d, staying_in_state_1, staying_in_state_2, staying_in_state_3, staying_in_state_4a, staying_in_state_4w, staying_in_state_4fd, staying_in_state_4d, staying_in_state_4, staying_in_state_5, staying_in_state_6;

wire [5:0] timer;

wire reset_bar;

assign reset_bar = ~reset;

//reg walk_request = 1'b0;


 // CLOCKS
 
// clocks for D flash   13500000/x = 1/0.05hz <-- if thats what you want
 
wire clk0_5;
reg [31:0] counter0_5;

// making 0.5hz clock
always @ (posedge clk_27)
if (counter0_5 < 32'd6750000)
	counter0_5 = counter0_5 + 1;
else
	begin
	counter0_5 = 32'd0;
	clk0_5 = ~clk0_5;
	end 
	

wire clk0_05;
reg [31:0] counter0_05;

// making 0.05hz clock
always @ (posedge clk_27)
if (counter0_05 < 32'd675000)
	counter0_05 = counter0_05 + 1;
else
	begin
	counter0_05 = 32'd0;
	clk0_05 = ~clk0_05;
	end 
	
 
// clocks for board
 
wire clk1;
reg [31:0] counter;

// making 1hz clock
always @ (posedge clk_27)
if (counter < 32'd13500000)
	counter = counter + 1;
else
	begin
	counter = 32'd0;
	clk1 = ~clk1;
	end
	
 
 // 10hz
wire clk_10;
reg [31:0] counter_10;

always @ (posedge clk_27)
if (counter_10 < 32'd1350000)
	counter_10 = counter_10 + 1;
else
	begin
	counter_10 = 32'd0;
	clk_10 = ~clk_10;
	end
	
	

reg clk_d;

	
	
// de_bug switch 
always @ *	
if (de_bug == 1'b1)
	begin
	clk = clk_10;
	clk_d = clk0_05;
	end
else
	begin
	clk = clk1;
	clk_d = clk0_5;
	end

	
	
	
	
// timer stuff

always @ (posedge clk or negedge reset)
if (reset == 1'b0)
	timer <= 6'd60; // state 1
	
else if (entering_state_1w == 1'b1)
		timer <= 6'd10; // state 1w
	
else if (entering_state_1fd == 1'b1)
		timer <= 6'd20; // state 1fd	
	
else if (entering_state_1d == 1'b1)
		timer <= 6'd30; // state 1d	
	
else if (entering_state_1 == 1'b1)
	timer <= 6'd60; // state 1
	
else if (entering_state_2 == 1'b1)
	timer <= 6'd6; // state 2
	
else if (entering_state_2s == 1'b1)
	timer <= 6'd20; // state 2
	
else if (entering_state_3 == 1'b1)
	timer <= 6'd2; // state 3
	
else if (entering_state_4a == 1'b1)
	timer <= 6'd20; // state 4a	
	
else if (entering_state_4w == 1'b1)
		timer <= 6'd10; // state 4w

else if (entering_state_4fd == 1'b1)
		timer <= 6'd20; // state 4fd			
	
else if (entering_state_4d == 1'b1)
		timer <= 6'd30; // state 4d		
	
else if (entering_state_4 == 1'b1)
	timer <= 6'd60; // state 4
	
else if (entering_state_5 == 1'b1)
	timer <= 6'd6; // state 5	

else if (entering_state_6 == 1'b1)
	timer <= 6'd2; // state 6	
	
//else if (entering_state_z == 1'b1)
//	timer <= 6'd60; // state 6	
	
else if (timer == 6'd1)
		timer <= timer;
		
else 
		timer <= timer - 6'd1;
	
reg walk_request;
// walk_request flipflop	NOTE: m
always @ (posedge clk or posedge reset_bar or negedge push_button[1])
	if (reset_bar == 1'b1) // keys are active low
		walk_request <= 1'b0;
	else if ((push_button[1] == 1'b0))
		walk_request = 1'b1;
	
	else if ((state_6 == 1'b1)&&(timer == 6'd1)&& (walk_request == 1'b1))
		walk_request = 1'b0;
		
	else if ((state_4a == 1'b1)&&(timer == 6'd1)&& (walk_request == 1'b1))
		walk_request = 1'b0;
		
	else if ((state_3 == 1'b1)&&(timer == 6'd1)&&(left_turn_request == 1'b1)&&(walk_request == 1'b1))
		walk_request = 1'b0;
		
	else
		walk_request = walk_request;
	
	

// STATE 1w	
	
// make the state 1w flip flop	
always @ (posedge clk or posedge reset_bar)
	if (reset_bar == 1'b1) // keys are active low
		state_1w <= 1'b0;
	else state_1w <= state_1w_d;

//logic for entering state 1w
always @ *
	if( (state_6 == 1'b1) && (walk_request == 1'b1) && (timer == 6'd1) )
		entering_state_1w <= 1'b1;

	else entering_state_1w <= 1'b0;
//logic for staying in state 1w
always @ *
	if( (state_1w == 1'b1) && (timer != 6'd1) )
		staying_in_state_1w <= 1'b1;
	else staying_in_state_1w <= 1'b0;
// make the d-input for state_1w flip/flop
always @ *
	if( entering_state_1w == 1'b1 )
		// enter state 1w on next posedge clk
		state_1w_d <= 1'b1;
	else if ( staying_in_state_1w == 1'b1)
		// stay in state 1w on next posedge clk
		state_1w_d <= 1'b1;
	else // not in state 1w on next posedge clk
		state_1w_d <= 1'b0;

		
		
		
// STATE 1fd	
	
// make the state 1fd flip flop	
always @ (posedge clk or posedge reset_bar)
	if (reset_bar == 1'b1) // keys are active low
		state_1fd <= 1'b0;
	else state_1fd <= state_1fd_d;

//logic for entering state 1fd
always @ *
	if( (state_1w == 1'b1) && (timer == 6'd1) )
		entering_state_1fd <= 1'b1;
	else entering_state_1fd <= 1'b0;
//logic for staying in state 1fd
always @ *
	if( (state_1fd == 1'b1) && (timer != 6'd1) )
		staying_in_state_1fd <= 1'b1;
	else staying_in_state_1fd <= 1'b0;
// make the d-input for state_1w flip/flop
always @ *
	if( entering_state_1fd == 1'b1 )
		// enter state 1fd on next posedge clk
		state_1fd_d <= 1'b1;
	else if ( staying_in_state_1fd == 1'b1)
		// stay in state 1fd on next posedge clk
		state_1fd_d <= 1'b1;
	else // not in state 1fd on next posedge clk
		state_1fd_d <= 1'b0;		
		
	
	
	
	
// STATE 1d	
	
// make the state 1d flip flop	
always @ (posedge clk or posedge reset_bar)
	if (reset_bar == 1'b1) // keys are active low
		state_1d <= 1'b0;
	else state_1d <= state_1d_d;

//logic for entering state 1d
always @ *
	if( (state_1fd == 1'b1) && (timer == 6'd1) )
		entering_state_1d <= 1'b1;
	else entering_state_1d <= 1'b0;
//logic for staying in state 1d
always @ *
	if( (state_1d == 1'b1) && (timer != 6'd1) )
		staying_in_state_1d <= 1'b1;
	else staying_in_state_1d <= 1'b0;
// make the d-input for state_1w flip/flop
always @ *
	if( entering_state_1d == 1'b1 )
		// enter state 1d on next posedge clk
		state_1d_d <= 1'b1;
	else if ( staying_in_state_1d == 1'b1)
		// stay in state 1d on next posedge clk
		state_1d_d <= 1'b1;
	else // not in state 1d on next posedge clk
		state_1d_d <= 1'b0;		
	
	
	
	
	
	

// STATE 1	
	
// make the state 1 flip flop	
always @ (posedge clk or posedge reset_bar)
	if (reset_bar == 1'b1) // keys are active low
		state_1 <= 1'b1;
	else state_1 <= state_1_d;

//logic for entering state 1
always @ *
	if( (((state_6 == 1'b1)&&(walk_request == 1'b0)) && (timer == 6'd1)) )
		entering_state_1 <= 1'b1;
	else entering_state_1 <= 1'b0;
//logic for staying in state 1
always @ *
	if( (state_1 == 1'b1) && (timer != 6'd1) )
		staying_in_state_1 <= 1'b1;
	else staying_in_state_1 <= 1'b0;
// make the d-input for state_1 flip/flop
always @ *
	if( entering_state_1 == 1'b1 )
		// enter state 1 on next posedge clk
		state_1_d <= 1'b1;
	else if ( staying_in_state_1 == 1'b1)
		// stay in state 1 on next posedge clk
		state_1_d <= 1'b1;
	else // not in state 1 on next posedge clk
		state_1_d <= 1'b0;


	
	
	
// STATE 2	
	
// make the state 2 flip flop	
always @ (posedge clk or posedge reset_bar)
	if (reset_bar == 1'b1) // keys are active low
		state_2 <= 1'b0;
	else state_2 <= state_2_d;

//logic for entering state 2
always @ *
	if( (state_1 == 1'b1) && (timer == 6'd1) )
		entering_state_2 <= 1'b1;	
	else if (((state_1d == 1'b1))  && (timer == 6'd1) )
		entering_state_2 <= 1'b1;
	else entering_state_2 <= 1'b0;
//logic for staying in state 2
always @ *
	if( (state_2 == 1'b1) && (timer != 6'd1) )
		staying_in_state_2 <= 1'b1;
	else staying_in_state_2 <= 1'b0;
// make the d-input for state_2 flip/flop
always @ *
	if( entering_state_2 == 1'b1 )
		// enter state 2 on next posedge clk
		state_2_d <= 1'b1;
	else if ( staying_in_state_2 == 1'b1)
		// stay in state 2 on next posedge clk
		state_2_d <= 1'b1;
	else // not in state 2 on next posedge clk
		state_2_d <= 1'b0;
		
		
		
// STATE 2s	
	
// make the state 2s flip flop	
always @ (posedge clk or posedge reset_bar)
	if (reset_bar == 1'b1) // keys are active low
		state_2s <= 1'b0;
	else state_2s <= state_2s_d;

//logic for entering state 2s
always @ *
	if( (state_2 == 1'b1) && (push_button[0] == 1'b0) && (timer == 6'd1) )
		entering_state_2s <= 1'b1;	
//	else if (((state_1d == 1'b1))  && (timer == 6'd1) )
//		entering_state_2s <= 1'b1;
	else entering_state_2s <= 1'b0;
//logic for staying in state 2s
always @ *
	if( (state_2s == 1'b1) && (timer != 6'd1) )
		staying_in_state_2s <= 1'b1;
	else staying_in_state_2s <= 1'b0;
// make the d-input for state_2s flip/flop
always @ *
	if( entering_state_2s == 1'b1 )
		// enter state 2s on next posedge clk
		state_2s_d <= 1'b1;
	else if ( staying_in_state_2s == 1'b1)
		// stay in state 2s on next posedge clk
		state_2s_d <= 1'b1;
	else // not in state 2s on next posedge clk
		state_2s_d <= 1'b0;

		
		
		
		
// STATE 3	
	
// make the state 3 flip flop	
always @ (posedge clk or posedge reset_bar)
	if (reset_bar == 1'b1) // keys are active low
		state_3 <= 1'b0;
	else state_3 <= state_3_d;

//logic for entering state 3
always @ *
	if( (((state_2 == 1'b1)&&(push_button[0] == 1'b1)) || (state_2s == 1'b1)) && (timer == 6'd1) )
		entering_state_3 <= 1'b1;
	else entering_state_3 <= 1'b0;
//logic for staying in state 3
always @ *
	if( (state_3 == 1'b1) && (timer != 6'd1) )
		staying_in_state_3 <= 1'b1;
	else staying_in_state_3 <= 1'b0;
// make the d-input for state_3 flip/flop
always @ *
	if( entering_state_3 == 1'b1 )
		// enter state 3 on next posedge clk
		state_3_d <= 1'b1;
	else if ( staying_in_state_3 == 1'b1)
		// stay in state 2 on next posedge clk
		state_3_d <= 1'b1;
	else // not in state 2 on next posedge clk
		state_3_d <= 1'b0;		

		
// STATE 4a	
	
// make the state 4a flip flop	
always @ (posedge clk or posedge reset_bar)
	if (reset_bar == 1'b1) // keys are active low
		state_4a <= 1'b0;
	else state_4a <= state_4a_d;

//logic for entering state 4a
always @ *
	if( (state_3 == 1'b1) && (left_turn_request == 1'b0) && (timer == 6'd1) )
		entering_state_4a <= 1'b1;
	else entering_state_4a <= 1'b0;
//logic for staying in state 4a
always @ *
	if( (state_4a == 1'b1) && (timer != 6'd1) )
		staying_in_state_4a <= 1'b1;
	else staying_in_state_4a <= 1'b0;
// make the d-input for state_4a flip/flop
always @ *
	if( entering_state_4a == 1'b1 )
		// enter state 4a on next posedge clk
		state_4a_d <= 1'b1;
	else if ( staying_in_state_4a == 1'b1)
		// stay in state 2 on next posedge clk
		state_4a_d <= 1'b1;
	else // not in state 2 on next posedge clk
		state_4a_d <= 1'b0;	


		


// STATE 4w	
	
// make the state 4w flip flop	
always @ (posedge clk or posedge reset_bar)
	if (reset_bar == 1'b1) // keys are active low
		state_4w <= 1'b0;
	else state_4w <= state_4w_d;

//logic for entering state 4w         NOTE: this prob needs to be fixed
always @ *
	if( (state_3 == 1'b1) && (left_turn_request == 1'b1)&&(walk_request == 1'b1) && (timer == 6'd1))
		entering_state_4w <= 1'b1;	
	else if ((state_4a == 1'b1) && (walk_request == 1'b1) && (timer == 6'd1) )
//	if( (state_3 == 1'b1) && (walk_request == 1'b1)&& (timer == 6'd1) )
		entering_state_4w <= 1'b1;

	else entering_state_4w <= 1'b0;
//logic for staying in state 4w
always @ *
	if( (state_4w == 1'b1) && (timer != 6'd1) )
		staying_in_state_4w <= 1'b1;
	else staying_in_state_4w <= 1'b0;
// make the d-input for state_4w flip/flop
always @ *
	if( entering_state_4w == 1'b1 )
		// enter state 4w on next posedge clk
		state_4w_d <= 1'b1;
	else if ( staying_in_state_4w == 1'b1)
		// stay in state 4w on next posedge clk
		state_4w_d <= 1'b1;
	else // not in state 4w on next posedge clk
		state_4w_d <= 1'b0;

		
		
		
// STATE 4fd	
	
// make the state 4fd flip flop	
always @ (posedge clk or posedge reset_bar)
	if (reset_bar == 1'b1) // keys are active low
		state_4fd <= 1'b0;
	else state_4fd <= state_4fd_d;

//logic for entering state 4fd
always @ *
	if( (state_4w == 1'b1) && (timer == 6'd1) )
		entering_state_4fd <= 1'b1;
	else entering_state_4fd <= 1'b0;
//logic for staying in state 4fd
always @ *
	if( (state_4fd == 1'b1) && (timer != 6'd1) )
		staying_in_state_4fd <= 1'b1;
	else staying_in_state_4fd <= 1'b0;
// make the d-input for state_4w flip/flop
always @ *
	if( entering_state_4fd == 1'b1 )
		// enter state 4fd on next posedge clk
		state_4fd_d <= 1'b1;
	else if ( staying_in_state_4fd == 1'b1)
		// stay in state 4fd on next posedge clk
		state_4fd_d <= 1'b1;
	else // not in state 4fd on next posedge clk
		state_4fd_d <= 1'b0;		
		
	
	
	
	
// STATE 4d	
	
// make the state 4d flip flop	
always @ (posedge clk or posedge reset_bar)
	if (reset_bar == 1'b1) // keys are active low
		state_4d <= 1'b0;
	else state_4d <= state_4d_d;

//logic for entering state 4d
always @ *
	if( (state_4fd == 1'b1) && (timer == 6'd1) )
		entering_state_4d <= 1'b1;
	else entering_state_4d <= 1'b0;
//logic for staying in state 4d
always @ *
	if( (state_4d == 1'b1) && (timer != 6'd1) )
		staying_in_state_4d <= 1'b1;
	else staying_in_state_4d <= 1'b0;
// make the d-input for state_4w flip/flop
always @ *
	if( entering_state_4d == 1'b1 )
		// enter state 4d on next posedge clk
		state_4d_d <= 1'b1;
	else if ( staying_in_state_4d == 1'b1)
		// stay in state 4d on next posedge clk
		state_4d_d <= 1'b1;
	else // not in state 4d on next posedge clk
		state_4d_d <= 1'b0;	






		
		
// STATE 4	
	
// make the state 4 flip flop	
always @ (posedge clk or posedge reset_bar)
	if (reset_bar == 1'b1) // keys are active low
		state_4 <= 1'b0;
	else state_4 <= state_4_d;

//logic for entering state 4
always @ *
	if ((state_4a == 1'b1)&&(walk_request == 1'b0)&&(timer == 6'd1))
		entering_state_4 <= 1'b1;
	else if (((state_3 == 1'b1)&&(left_turn_request == 1'b1)&&(walk_request == 1'b0)) && (timer == 6'd1))
		entering_state_4 <= 1'b1;	
		
	else entering_state_4 <= 1'b0;
//logic for staying in state 4
always @ *
	if( (state_4 == 1'b1) && (timer != 6'd1) )
		staying_in_state_4 <= 1'b1;
	else staying_in_state_4 <= 1'b0;
// make the d-input for state_4 flip/flop
always @ *
	if( entering_state_4 == 1'b1 )
		// enter state 4 on next posedge clk
		state_4_d <= 1'b1;
	else if ( staying_in_state_4 == 1'b1)
		// stay in state 4 on next posedge clk
		state_4_d <= 1'b1;
	else // not in state 4 on next posedge clk
		state_4_d <= 1'b0;




// STATE 5	
	
// make the state 5 flip flop	
always @ (posedge clk or posedge reset_bar)
	if (reset_bar == 1'b1) // keys are active low
		state_5 <= 1'b0;
	else state_5 <= state_5_d;

//logic for entering state 5
always @ *
	if( ((state_4 == 1'b1) || (state_4d ==1'b1)) && (timer == 6'd1) )
		entering_state_5 <= 1'b1;
	else entering_state_5 <= 1'b0;
//logic for staying in state 5
always @ *
	if( (state_5 == 1'b1) && (timer != 6'd1) )
		staying_in_state_5 <= 1'b1;
	else staying_in_state_5 <= 1'b0;
// make the d-input for state_5 flip/flop
always @ *
	if( entering_state_5 == 1'b1 )
		// enter state 5 on next posedge clk
		state_5_d <= 1'b1;
	else if ( staying_in_state_5 == 1'b1)
		// stay in state 5 on next posedge clk
		state_5_d <= 1'b1;
	else // not in state 2 on next posedge clk
		state_5_d <= 1'b0;	
	




// STATE 6	
	
// make the state 6 flip flop	
always @ (posedge clk or posedge reset_bar)
	if (reset_bar == 1'b1) // keys are active low
		state_6 <= 1'b0;
	else state_6 <= state_6_d;

//logic for entering state 6
always @ *
	if( (state_5 == 1'b1) && (timer == 6'd1) )
		entering_state_6 <= 1'b1;
	else entering_state_6 <= 1'b0;
//logic for staying in state 6
always @ *
	if( (state_6 == 1'b1) && (timer != 6'd1) )
		staying_in_state_6 <= 1'b1;
	else staying_in_state_6 <= 1'b0;
// make the d-input for state_6 flip/flop
always @ *
	if( entering_state_6 == 1'b1 )
		// enter state 6 on next posedge clk
		state_6_d <= 1'b1;
	else if ( staying_in_state_6 == 1'b1)
		// stay in state 6 on next posedge clk
		state_6_d <= 1'b1;
	else // not in state 6 on next posedge clk
		state_6_d <= 1'b0;	
	
	
//// STATE Z	
//	
//// make the state z flip flop	
//always @ (posedge clk or posedge reset_bar)
//	if (reset_bar == 1'b1) // keys are active low
//		state_z <= 1'b0;
//	else state_z <= state_z_d;
//
////logic for entering state z
//always @ *
//	if( (state_6 == 1'b1) && (timer == 6'd1) )
//		entering_state_z <= 1'b1;
//	else entering_state_z <= 1'b0;
////logic for staying in state z
//always @ *
//	if( (state_z == 1'b1) && (timer != 6'd1) )
//		staying_in_state_z <= 1'b1;
//	else staying_in_state_z <= 1'b0;
//// make the d-input for state_z flip/flop
//always @ *
//	if( entering_state_z == 1'b1 )
//		// enter state z on next posedge clk
//		state_z_d <= 1'b1;
//	else if ( staying_in_state_z == 1'b1)
//		// stay in state z on next posedge clk
//		state_z_d <= 1'b1;
//	else // not in state z on next posedge clk
//		state_z_d <= 1'b0;	
	
// state_2s

//always @ (posedge clk_d)
//if (state_1fd == 1'b1)
//	WBnd_FD = ~WBnd_FD;	
//
//always @ (posedge clk_d)
//if (state_2s == 1'b1)
//		begin
//		eastbound_red = ~eastbound_red;
//		westbound_red = ~westbound_red;
//		southbound_red = ~southbound_red;
//		northbound_red = ~northbound_red;
//		end
//else
//		begin
//		eastbound_red = eastbound_red;
//		westbound_red = westbound_red;
//		southbound_red = southbound_red;
//		northbound_red = northbound_red;
//		end

	
	
	
// EAST BOUND	

// RED	
always @ (posedge clk_d)
if (state_2s == 1'b1)
	eastbound_red = ~eastbound_red;
else if ((state_3 | state_4 | state_5 | state_6 | state_4a | state_4w | state_4fd | state_4d) == 1'b1) 
		eastbound_red = 1'b0;
else
		eastbound_red = 1'b1;
		
// AMBER
always @ *
if (state_2 == 1'b1)
	eastbound_amber = 1'b0;
else
	eastbound_amber = 1'b1;

// GREEN
always @ *
if ((state_1 | state_1w | state_1fd | state_1d) == 1'b1)
	eastbound_green = 1'b0;
else
	eastbound_green = 1'b1;
		
		
		
// North Bound	

// RED	
always @ (posedge clk_d)
	if (state_2s == 1'b1)
		northbound_red = ~northbound_red;
else if ((state_1 | state_2 | state_3 | state_6 | state_4a | state_1w | state_1fd | state_1d) == 1'b1) 
		northbound_red = 1'b0;
else
		northbound_red = 1'b1;
		
// AMBER
always @ *
if (state_5 == 1'b1)
	northbound_amber = 1'b0;
else
	northbound_amber = 1'b1;

// GREEN
always @ *
if ((state_4 | state_4w | state_4fd | state_4d) == 1'b1)
	northbound_green = 1'b0;
else
	northbound_green = 1'b1;		
		




// South Bound	

// RED	
always @ (posedge clk_d)
	if (state_2s == 1'b1)
		southbound_red = ~southbound_red;
else if ((state_1 | state_2 | state_3 | state_6 | state_1w | state_1fd | state_1d) == 1'b1) 
		southbound_red = 1'b0; // on because negative logic
else
		southbound_red = 1'b1; // off
		
// AMBER
always @ *
if ((state_5 == 1'b1) | (state_4a == 1'b1))
	southbound_amber = 1'b0;
else
	southbound_amber = 1'b1;

// GREEN
always @ *
if ((state_4 | state_4w | state_4fd | state_4d) == 1'b1)
	southbound_green = 1'b0;
else
	southbound_green = 1'b1;
	
//Arrow
always @ *
if (state_4a == 1'b1)
	southbound_arrow = 2'b00;
	
else
	southbound_arrow = 2'b11;


	
	
	
	

// West Bound	

// RED	
always @ (posedge clk_d)
	if (state_2s == 1'b1)
		westbound_red = ~westbound_red;
else if ((state_3 | state_4 | state_5 | state_6 | state_4a | state_4w | state_4fd | state_4d) == 1'b1) 
		westbound_red = 1'b0;
else
		westbound_red = 1'b1;
		
// AMBER
always @ *
if (state_2 == 1'b1)
	westbound_amber = 1'b0;
else
	westbound_amber = 1'b1;

// GREEN
always @ *
if ((state_1 | state_1w | state_1fd | state_1d) == 1'b1)
	westbound_green = 1'b0;
else
	westbound_green = 1'b1;		
	


// NBnd Walk
// D
always @ *
if (state_1w | state_1fd | state_1d | state_1 | state_2 | state_3 | state_4a | state_4d | state_4 | state_5 | state_6)
	NBnd_D = 5'b00000;

else 
	NBnd_D = 5'b11111;

// W
always @ (posedge clk_d)
if (state_4w == 1'b1)
	NBnd_W = 1'b0;
	
else
	NBnd_W = 1'b1;

// FD
always @ (posedge clk_d)
if (state_4w == 1'b1)
	NBnd_FD = 5'b11111;
	
else if (state_4fd == 1'b1)
	NBnd_FD = ~NBnd_FD;	
	
else 
	NBnd_FD = 5'b00000;
	
	
	
// SBnd Walk	
// D
always @ *
if (state_1w | state_1fd | state_1d | state_1 | state_2 | state_3 | state_4a | state_4d | state_4 | state_5 | state_6)
	SBnd_D = 5'b00000;

else 
	SBnd_D = 5'b11111;

// W
always @ (posedge clk_d)
if (state_4w == 1'b1)
	SBnd_W = 1'b0;
	
else
	SBnd_W = 1'b1;

// FD
always @ (posedge clk_d)
if (state_4w == 1'b1)
	SBnd_FD = 5'b11111;

else if (state_4fd == 1'b1)
	SBnd_FD = ~SBnd_FD;		
	
else 
	SBnd_FD = 5'b00000;


	
	
// EBnd Walk
// D
always @ *
if (state_1d | state_1 | state_2 | state_3 | state_4a | state_4w | state_4fd | state_4d | state_4 | state_5 | state_6)
	EBnd_D = 5'b00000;

else 
	EBnd_D = 5'b11111;

// W
always @ (posedge clk_d)
if (state_1w == 1'b1)
	EBnd_W = 1'b0;
	
else
	EBnd_W = 1'b1;

// FD
always @ (posedge clk_d)	
if (state_1w == 1'b1)
	EBnd_FD = 5'b11111;
	
else if (state_1fd == 1'b1)
	EBnd_FD = ~EBnd_FD;	
	
else 
	EBnd_FD = 5'b00000;	
	
	
	
	
// WBnd Walk
// D
always @ *
if (state_1d | state_1 | state_2 | state_3 | state_4a | state_4w | state_4fd | state_4d | state_4 | state_5 | state_6)
	WBnd_D = 5'b00000;

	
else 
	WBnd_D = 5'b11111;

// W
always @ (posedge clk_d)
if (state_1w == 1'b1)
	WBnd_W = 1'b0;
	
else
	WBnd_W = 1'b1;

// FD
always @ (posedge clk_d)
if (state_1fd == 1'b1)
	WBnd_FD = ~WBnd_FD;	
	
else if (state_1w == 1'b1)
	WBnd_FD = 5'b11111;
	
else 
	WBnd_FD = 5'b00000;
	
		
endmodule


// note: my D flashes at 1hz needs to be 0.5hz
// on TB when i can press walk trigger might be an issue  

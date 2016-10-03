`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:50:41 03/29/2015 
// Design Name: 
// Module Name:    ex4 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module ex4_s(   //7 segment display
input [3:0] NUM, 
output reg[6:0] a_to_g 
); 
always @(*) 
case(NUM) 
0:a_to_g=7'b0000001; 
1:a_to_g=7'b1001111; 
2:a_to_g=7'b0010010; 
3:a_to_g=7'b0000110; 
4:a_to_g=7'b1001100; 
5:a_to_g=7'b0100100; 
6:a_to_g=7'b0100000; 
7:a_to_g=7'b0001111; 
8:a_to_g=7'b0000000; 
9:a_to_g=7'b0000100; 
'hA: a_to_g=7'b0001000; 
'hB: a_to_g=7'b1100000; 
'hC: a_to_g=7'b0110001; 
'hD: a_to_g=7'b1000010; 
'hE: a_to_g=7'b0110000; 
'hF: a_to_g=7'b0111000; 
default: a_to_g=7'b0000001; 
endcase 
endmodule 

module ex4_t( 
input clk,      //clk
input temp_a,   //four button
input temp_b,
input temp_c,
input temp_d,
input switch1,  // Two switch
input switch2,
input switch5,  //The 5,6,7,8 switch is for test the program(show the right answer),please ignore these input
input switch6,
input switch7,
input switch8,
output[3:0]ans,//enable signal for the display 
output[6:0]a_to_g, //7-segment display
output reg[7:0]light//7 led light for life number
); 
reg[3:0]an; //save the state of ans
reg[23:0] clk_cnt; //divide the frequency
reg[25:0] delay;   //delay a short time
reg [3:0] NUM;     // save the number
reg [3:0] equal;   //see if the digital numbers are same  
reg [2:0]rightpos; //both value and position are right(m in mAnb) 
reg [2:0]rightnum;//only value is right(n in mAnb)
reg [16:0] s ;    //divide the frequency
reg [16:0] t;
reg [16:0] r;
reg [3:0]answer1;//save the answer
reg [3:0]answer2;
reg [3:0]answer3;
reg [3:0]answer4;

reg [3:0] temp_1 ; //save the input 
reg [3:0] temp_2 ; 
reg [3:0] temp_3 ; 
reg [3:0] temp_4 ; 
reg[3:0] life; //life
reg flag;      //control flag
reg flag1;
always @(posedge clk) 
begin 
clk_cnt = clk_cnt + 1; 
end

always @( posedge clk_cnt[23]) //Input part
begin
if((switch1)&(~switch2)) 
begin
if(temp_a)
begin
temp_1 = temp_1+1; 
if(temp_1 == 10) temp_1 = 0; 
end
end
if(~switch1)temp_1=0;
end 
always @( posedge clk_cnt[23]) 
begin 
if((switch1)&(~switch2)) 
begin
if(temp_b)
begin
temp_2 = temp_2+1; 
if(temp_2 == 10) temp_2 = 0; 
end
end
if(~switch1)temp_2=0; 
end
always @( posedge clk_cnt[23]) 
begin 
if((switch1)&(~switch2)) 
begin
if(temp_c)
begin
temp_3 = temp_3+1; 
if(temp_3 == 10) temp_3 = 0; 
end
end 
if(~switch1)temp_3=0;
end
always @( posedge clk_cnt[23]) 
begin 
if((switch1)&(~switch2)) 
begin
if(temp_d)
begin
temp_4 = temp_4+1; 
if(temp_4 == 10) temp_4 = 0; 
end
end 
if(~switch1)temp_4=0;
end

always @( posedge clk) //divide the frequency
begin 
s = s+1; 
if(s[16]) 
s = 0; 
end

always @( posedge clk) 
begin
if(~switch1)
begin 
r = r+1; 
if(r[16]) 
r = 0;
end 
end

always @( posedge clk_cnt[23]) //Generate an answer with four different digital number
begin
if((switch1)&(life>0))
begin 
if(r[3:0]>9)t[3:0]=r[3:0]-8;
if(r[7:4]>9)t[7:4]=r[7:4]-9; 
if(r[11:8]>9)t[11:8]=r[11:8]-6;
if(r[15:12]>9)t[15:12]=r[15:12]-7;
if(r[3:0]<9)t[3:0]=r[3:0];
if(r[7:4]<9)t[7:4]=r[7:4]; 
if(r[11:8]<9)t[11:8]=r[11:8];
if(r[15:12]<9)t[15:12]=r[15:12];
if(t[15:12]==t[11:8])begin if(t[11:8]==9)t[11:8]=0;t[11:8]=t[11:8]+1;end
if(t[15:12]==t[11:8])begin if(t[11:8]==9)t[11:8]=0;t[11:8]=t[11:8]+1;end
if(t[15:12]==t[11:8])begin if(t[11:8]==9)t[11:8]=0;t[11:8]=t[11:8]+1;end
if(t[15:12]==t[11:8])begin if(t[11:8]==9)t[11:8]=0;t[11:8]=t[11:8]+1;end
if(t[15:12]==t[11:8])begin if(t[11:8]==9)t[11:8]=0;t[11:8]=t[11:8]+1;end
if(t[15:12]==t[11:8])begin if(t[11:8]==9)t[11:8]=0;t[11:8]=t[11:8]+1;end
if(t[15:12]==t[11:8])begin if(t[11:8]==9)t[11:8]=0;t[11:8]=t[11:8]+1;end
if(t[15:12]==t[11:8])begin if(t[11:8]==9)t[11:8]=0;t[11:8]=t[11:8]+1;end
if(t[15:12]==t[11:8])begin if(t[11:8]==9)t[11:8]=0;t[11:8]=t[11:8]+1;end
if((t[7:4]==t[15:12])|(t[7:4]==t[11:8]))begin if(t[7:4]==9)t[7:4]=0;t[7:4]=t[7:4]+1; end
if((t[7:4]==t[15:12])|(t[7:4]==t[11:8]))begin if(t[7:4]==9)t[7:4]=0;t[7:4]=t[7:4]+1; end
if((t[7:4]==t[15:12])|(t[7:4]==t[11:8]))begin if(t[7:4]==9)t[7:4]=0;t[7:4]=t[7:4]+1; end
if((t[7:4]==t[15:12])|(t[7:4]==t[11:8]))begin if(t[7:4]==9)t[7:4]=0;t[7:4]=t[7:4]+1; end
if((t[7:4]==t[15:12])|(t[7:4]==t[11:8]))begin if(t[7:4]==9)t[7:4]=0;t[7:4]=t[7:4]+1; end
if((t[7:4]==t[15:12])|(t[7:4]==t[11:8]))begin if(t[7:4]==9)t[7:4]=0;t[7:4]=t[7:4]+1; end
if((t[7:4]==t[15:12])|(t[7:4]==t[11:8]))begin if(t[7:4]==9)t[7:4]=0;t[7:4]=t[7:4]+1; end
if((t[7:4]==t[15:12])|(t[7:4]==t[11:8]))begin if(t[7:4]==9)t[7:4]=0;t[7:4]=t[7:4]+1; end
if((t[7:4]==t[15:12])|(t[7:4]==t[11:8]))begin if(t[7:4]==9)t[7:4]=0;t[7:4]=t[7:4]+1; end
if((t[3:0]==t[15:12])|(t[3:0]==t[11:8])|(t[3:0]==t[7:4]))begin if(t[3:0]==9)t[3:0]=0;t[3:0]=t[3:0]+1; end 
if((t[3:0]==t[15:12])|(t[3:0]==t[11:8])|(t[3:0]==t[7:4]))begin if(t[3:0]==9)t[3:0]=0;t[3:0]=t[3:0]+1; end 
if((t[3:0]==t[15:12])|(t[3:0]==t[11:8])|(t[3:0]==t[7:4]))begin if(t[3:0]==9)t[3:0]=0;t[3:0]=t[3:0]+1; end 
if((t[3:0]==t[15:12])|(t[3:0]==t[11:8])|(t[3:0]==t[7:4]))begin if(t[3:0]==9)t[3:0]=0;t[3:0]=t[3:0]+1; end 
if((t[3:0]==t[15:12])|(t[3:0]==t[11:8])|(t[3:0]==t[7:4]))begin if(t[3:0]==9)t[3:0]=0;t[3:0]=t[3:0]+1; end 
if((t[3:0]==t[15:12])|(t[3:0]==t[11:8])|(t[3:0]==t[7:4]))begin if(t[3:0]==9)t[3:0]=0;t[3:0]=t[3:0]+1; end 
if((t[3:0]==t[15:12])|(t[3:0]==t[11:8])|(t[3:0]==t[7:4]))begin if(t[3:0]==9)t[3:0]=0;t[3:0]=t[3:0]+1; end 
if((t[3:0]==t[15:12])|(t[3:0]==t[11:8])|(t[3:0]==t[7:4]))begin if(t[3:0]==9)t[3:0]=0;t[3:0]=t[3:0]+1; end 
if((t[3:0]==t[15:12])|(t[3:0]==t[11:8])|(t[3:0]==t[7:4]))begin if(t[3:0]==9)t[3:0]=0;t[3:0]=t[3:0]+1; end 
answer1=t[3:0];
answer2=t[7:4];
answer3=t[11:8];
answer4=t[15:12];
end 
end

assign ans=an; 
always @(posedge clk)
begin
if((switch1)&(~switch5)&(~switch2)&(life>0)&(rightpos<4))//normal situation
begin 
equal=0;
flag=0;
rightpos=0;
rightnum=0;
case(s[15:14]) 
0:begin NUM = temp_1;an[0]=1;an[1]=1;an[2]=1;an[3]=0;end  
1:begin NUM = temp_2;an[0]=1;an[1]=1;an[2]=0;an[3]=1;end 
2:begin NUM = temp_3;an[0]=1;an[1]=0;an[2]=1;an[3]=1;end  
3:begin NUM = temp_4;an[0]=0;an[1]=1;an[2]=1;an[3]=1;end 
endcase
end
else if((switch1)&(switch5)&(switch6)&(switch7)&(switch8)&(~switch2))//For test,please ignore this part(show the right answer by turn on switcn 1,5,6,7,8)
begin
case(s[15:14]) 
0:begin NUM = answer1;an[0]=1;an[1]=1;an[2]=1;an[3]=0;end  
1:begin NUM = answer2;an[0]=1;an[1]=1;an[2]=0;an[3]=1;end 
2:begin NUM = answer3;an[0]=1;an[1]=0;an[2]=1;an[3]=1;end  
3:begin NUM = answer4;an[0]=0;an[1]=1;an[2]=1;an[3]=1;end
endcase 
end
else if(~switch1)//initialization
begin
an[0]=1;an[1]=1;an[2]=1;an[3]=1;flag=0;life=8;
light=8'b11111111;delay=0;flag1=0;rightnum=0;rightpos=0;equal=0;
end
else if((switch1)&(switch2))//judge
	begin//if there are same numbers, blink
	if(temp_1==temp_2)begin equal[0]=1;equal[1]=1;end
	if(temp_1==temp_3)begin equal[0]=1;equal[2]=1;end
	if(temp_1==temp_4)begin equal[0]=1;equal[3]=1;end
	if(temp_2==temp_3)begin equal[1]=1;equal[2]=1;end
	if(temp_2==temp_4)begin equal[1]=1;equal[3]=1;end
	if(temp_3==temp_4)begin equal[2]=1;equal[3]=1;end
	
	if(equal[3:0]==0)//if not, judging begins
		begin
		if(flag==0)
		begin
		flag=1;//--life
		if(life>0)life=life-1;
		if(life==8)light=8'b11111111;
		else if(life==7)light=8'b11111110;
		else if(life==6)light=8'b11111100;
		else if(life==5)light=8'b11111000;
		else if(life==4)light=8'b11110000;
		else if(life==3)light=8'b11100000;
		else if(life==2)light=8'b11000000;
		else if(life==1)light=8'b10000000;
		else if(life==0)light=8'b00000000;
		end
		rightpos=(temp_1==answer1)+(temp_4==answer4)+(temp_2==answer2)+(temp_3==answer3);
		rightnum=(temp_1==answer2)+(temp_1==answer3)+(temp_1==answer4)+(temp_2==answer1)+(temp_2==answer3)+(temp_2==answer4)+(temp_3==answer1)+(temp_3==answer2)+(temp_3==answer4)+(temp_4==answer1)+(temp_4==answer2)+(temp_4==answer3);
		//caculate m,n (mAnb)
		case(s[15:14]) //show mAnb
		0:begin NUM = 11;an[0]=1;an[1]=1;an[2]=1;an[3]=0;end  
		1:begin NUM = rightnum;an[0]=1;an[1]=1;an[2]=0;an[3]=1;end 
		2:begin NUM = 10;an[0]=1;an[1]=0;an[2]=1;an[3]=1;end  
		3:begin NUM = rightpos;an[0]=0;an[1]=1;an[2]=1;an[3]=1;end
		endcase
		if(rightpos==4) //if win
			begin
				begin			
				if(clk_cnt[23])
				an=4'b1111;
				else
					begin
					case(s[15:14]) 
						0:begin NUM = 11;an[0]=1;an[1]=1;an[2]=1;an[3]=0;end  
						1:begin NUM = rightnum;an[0]=1;an[1]=1;an[2]=0;an[3]=1;end 
						2:begin NUM = 10;an[0]=1;an[1]=0;an[2]=1;an[3]=1;end  
						3:begin NUM = rightpos;an[0]=0;an[1]=1;an[2]=1;an[3]=1;end
					endcase
					end
		
				end
			end
		else if(life==0) //if no life and not win
			begin
			if(flag1==0)delay=delay+1;
			if(delay[25]==1)
				begin
				flag1=1;
				if(clk_cnt[23])
				an=4'b1111;
				else
					begin
					case(s[15:14]) 
					0:begin NUM = answer1;an[0]=1;an[1]=1;an[2]=1;an[3]=0;end  
					1:begin NUM = answer2;an[0]=1;an[1]=1;an[2]=0;an[3]=1;end 
					2:begin NUM = answer3;an[0]=1;an[1]=0;an[2]=1;an[3]=1;end  
					3:begin NUM = answer4;an[0]=0;an[1]=1;an[2]=1;an[3]=1;end 
					endcase
					end
				end
			end
				
			
		end
	else
		begin
	
		if(clk_cnt[23])
	    an=4'b1111;
		else
			begin
				case(s[15:14]) 
			0:begin NUM = temp_1;an[0]=1;an[1]=1;an[2]=1;an[3]=~equal[0];end  
			1:begin NUM = temp_2;an[0]=1;an[1]=1;an[2]=~equal[1];an[3]=1;end 
			2:begin NUM = temp_3;an[0]=1;an[1]=~equal[2];an[2]=1;an[3]=1;end  
			3:begin NUM = temp_4;an[0]=~equal[3];an[1]=1;an[2]=1;an[3]=1;end 
				endcase
			end
		end
			
	end
	else if((switch1)&(~switch5)&(~switch2)&(life==0)&(rightpos<4))//if lose
		begin			
			if(clk_cnt[23])
			an=4'b1111;
			else
				begin
				case(s[15:14]) 
				0:begin NUM = answer1;an[0]=1;an[1]=1;an[2]=1;an[3]=0;end  
				1:begin NUM = answer2;an[0]=1;an[1]=1;an[2]=0;an[3]=1;end 
				2:begin NUM = answer3;an[0]=1;an[1]=0;an[2]=1;an[3]=1;end  
				3:begin NUM = answer4;an[0]=0;an[1]=1;an[2]=1;an[3]=1;end 
				endcase
				end
		
		end
	else if((switch1)&(~switch5)&(~switch2)&(rightpos==4)) //if win
		begin			
					if(clk_cnt[23])
					an=4'b1111;
					else
					begin
						case(s[15:14]) 
						0:begin NUM = 11;an[0]=1;an[1]=1;an[2]=1;an[3]=0;end  
						1:begin NUM = rightnum;an[0]=1;an[1]=1;an[2]=0;an[3]=1;end 
						2:begin NUM = 10;an[0]=1;an[1]=0;an[2]=1;an[3]=1;end  
						3:begin NUM = rightpos;an[0]=0;an[1]=1;an[2]=1;an[3]=1;end
						endcase
					end
		
		end

end
ex4_s A1(.NUM(NUM),
.a_to_g(a_to_g));
endmodule

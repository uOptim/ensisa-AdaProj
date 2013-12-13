with Robot.Safe_Trajectory;

with Ada.Text_IO;
with Ada.Real_Time;


package body Robot is
	package IO renames Ada.Text_IO;
	package RT renames Ada.Real_Time;

	package Route is new Robot.Safe_Trajectory;

	use type Ada.Real_Time.Time, Ada.Real_Time.Time_Span;

	task body Object is
		T:  Route.Object;
		ID: Work_Site.Bot_ID;
		Tick_Time, Next_Tick: RT.Time;
	begin
		ID_Distributor.Get_ID(ID);
		IO.Put_Line("I am robot number" & Positive'Image(ID));

		Tick_Time := RT.Clock;
		Next_Tick := Tick_Time + RT.Milliseconds(Integer(1000.0*dt));

		loop
			select
				accept Go(From: Work_Site.In_Place; To: Work_Site.Out_Place) do
					T.Open(From, To);
				end;
				Work_Site.Traffic.Update_Position(
					ID, Work_Site.Position'(Integer(T.X), Integer(T.Y))
				);
			or
				when not T.Is_Done => delay until Next_Tick;
				Tick_Time := RT.Clock;
				Next_Tick := Tick_Time + RT.Milliseconds(Integer(1000.0*dt));
				T.Next(dt);
				if T.Is_Done then
					MBox.Put(ID);
					T.Close;
				end if;
				Work_Site.Traffic.Update_Position(
					ID, Work_Site.Position'(Integer(T.X), Integer(T.Y))
				);
			or
				accept Shutdown;
				IO.Put_Line("Robot" & Positive'Image(ID) & " shuting down");
				if (not T.Is_Done) then
					T.Close;
				end if;
				exit;
			end select;
		end loop;
	end;


	protected body ID_Distributor is
		procedure Get_ID (Rbt_ID: out Work_Site.Bot_ID) is
		begin
			-- Will raise range exception if the work site can't handle more bots
			-- which is fine.
			ID := ID + 1;
			Rbt_ID := ID;
		end;
	end ID_Distributor;

end;

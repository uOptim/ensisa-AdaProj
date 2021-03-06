package body Robot.Trajectory is

	function X(T: Object) return Float is
		(Path.X(T.Route, T.Segment, T.K));

	function Y(T: Object) return Float is
		(Path.Y(T.Route, T.Segment, T.K));

	function Route(T: Object) return Path.Object is
		(T.Route);

	function Places(T: Object) return Path_Maker.Place_Name_Array is
		(Path_Maker.Value(T.PM));

	function Segment(T: Object) return Positive is
		(T.Segment);

	procedure Next(T: in out Object; dt: Float) is
		dK: Float;
	begin
		if T.Done then return; end if;

		dk  := (T.Speed / Path.Segment_Length(T.Route, T.Segment)) * dt;
		T.K := T.K + dK;
		while T.K > 1.0 loop
			T.K       := T.K - 1.0;
			T.Segment := T.Segment + 1;
		end loop;

		if T.Segment > Path.Segment_Count(T.Route) then
			T.K       := 1.0;
			T.Done    := True;
			T.Segment := Path.Segment_Count(T.Route);
		end if;
	end;

	function Is_Done(T: Object) return Boolean is
		(T.Done);

	procedure Open (
		T: in out Object;
		From: Work_Site.In_Place; To: Work_Site.Out_Place;
		Speed: Float := 100.0
	) is
	begin
		T.Speed   := Speed;
		T.PM      := Path_Maker.Open(From, To);
		T.Route   := Path_Maker.Get_Path(T.PM);
		T.Segment := 1;
		if Path.Segment_Count(T.Route) = 0 then
			T.Done := True;
		else
			T.Done := False;
		end if;
	end;

	procedure Close(T: in out Object) is
	begin
		T.Done := True;
		Path_Maker.Close(T.PM);
	end;
end;

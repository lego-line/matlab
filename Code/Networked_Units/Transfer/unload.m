% unload.m - a script containing the routine to unload the pallet from the
% end of the feed line onto the mainline when called by the transfer_x
% script.
%%%%%%%%%%%%%%%%%%NETWORKED UNITS VERSION%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Running Unload Script') 
toc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Motor commands to raise paltform on mainlien for reception  
if GetSwitch(SENSOR_2, adder) == 0
    disp('the motor is still running')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if GetSwitch(SENSOR_2, adder) == 1&& unload_state == 1 && eval(['Pallet_Status_',num2str(Transfer_id)]) == 1
	down.WaitFor(0,adder);
	up.SendToNXT(adder);
    unload_state =2;
    disp('Finished First If Loop Unload Script Platform is Being raised ')
    toc
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if   unload_state == 1 && State_Read(length(State_Read)) == 1
        if error_loop_iteration > 3
            Failure_Flag_flag = 1;
            Kill_Line
            error_type = 'The Pallet Has Got Stuck Between the Feed Sensor and The Transfer Point';
            Network_Write;
        else    
            disp('FAULT: PALLET IS NOT AT THE TRANSFER POSITION')
            error_loop_iteration =error_loop_iteration + 1;
            fault_flag = 1;
            Network_Write;
            disp('Moving Pallets Forward')
            step_correction.SendToNXT(adder)
            step_correction.WaitFor(0,adder)
        end 
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if motoron.IsRunning == 0 && unload_state == 1 && eval(['Pallet_Status_',num2str(Transfer_id)]) == 0
        if error_loop_iteration > 3
            fault_flag = 1;
            error_type = 'The Pallet Has Got Stuck Between the Feed Sensor and The Transfer Point';
            Network_Write;
        else    
            disp('FAULT: PALLET IS NOT AT THE TRANSFER POSITION')
            error_loop_iteration =   error_loop_iteration + 1;
            fault_flag = 1;
            Network_Write;
            disp('Moving Pallets Forward')
            step_correction.SendToNXT(adder)
            step_correction.WaitFor(0,adder)
        end 
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Once the platform is raised then the arm can start moving, setup motor B
% appropriately 
motoron = up.ReadFromNXT(adder);
if motoron.IsRunning == 0 && unload_state ==2 
    disp('Platform is raised') 
    toc
    retract.WaitFor(0,adder);
    % Added 01/11/2011 as part of fault detection and response of transfer arm getting stuck.
    disp('Defining Motor B and resetting Tacho count')
    mB = NXTMotor('B'); 
    mB.ResetPosition(adder);
    t_arm_start=toc; % timer to note when the arm has begun moving to time journey
    add.SendToNXT(adder);
    unload_state=3;
    disp('Finished Second If Loop Unload Script Tacho Is Set Up For Rotation ')
    toc
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Added 01/11/2011 Fault detection and response of transfer arm getting
% stuck, arm is moving to destination, check time and power 
if unload_state == 3
    disp('checking whether transfer arm gets stuck...')
    toc
    data = mB.ReadFromNXT(adder);
    angle = data.Position;
	if angle < 100 && (toc-t_arm_start) > 2.5
         for tone_loop = 1:3
             for tone = 400:800
                 NXT_PlayTone(tone, 2, adder)
             end
         end
         mB.Stop('off',adder);
         mB.TachoLimit = -angle;	
         mB.Power = 10;
         mB.SendToNXT(adder);
         disp('The Arm Has Got Stuck, Retracting Arm')
         toc
         mB.WaitFor(0,adder);
         disp('Moving Belt Forward To Remove Blockage')
         toc
         step_correction.SendToNXT(adder)
         step_correction.WaitFor(0,adder)
         error_loop_iteration =   error_loop_iteration + 1;
         disp('Reattempting to Transfer The Pallet')
         % 5/7/12 Arm Coorection code here?
         unload_state= 2;
         disp('Finished Third If - Loop Arm has got stuck')
         toc
         unload_retry_flag = 1; 
	end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Section of Code to hold until the arm has completed its transfer of the
% pallet to the mainline 
motoron = add.ReadFromNXT(adder);
if motoron.IsRunning == 0 && unload_state ==3
    add.WaitFor(0,adder);
    data = add.ReadFromNXT(adder); 
    angle = data.Position;
    retract.TachoLimit = - angle ;
    retract.SendToNXT(adder);
    % error correction case to move back any other pallets whose positions
    % have also been modified by the attempt to correct the blockage 
    if unload_retry_flag == 1
        disp('Moving Any Disturbed Pallets back Inot Position')
        step_correction_reverse.SendToNXT(adder)
        unload_retry_flag =0;
    end 
    unload_state=4;
    disp('Finished Fourth if Loop Arm Transfer Completed')
    toc
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% once the arm has completed its journey, retract the arm and begin
% lowering the pallet onto the mainline 
motoron = retract.ReadFromNXT(adder);
if motoron.IsRunning == 0 && unload_state ==4
    up.WaitFor(0,adder);
    down.SendToNXT(adder);	
    unload_state=5;
    disp('Platform Lowering has Begun')
    toc
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% once the unlaoding has competle reset the unlaod state and update the
% state to conffirm package has been transferred
motoron = down.ReadFromNXT(adder);
if motoron.IsRunning == 0 && unload_state ==5
    if GetSwitch(SENSOR_2, adder) == 0
        adderarmreset.SendToNXT(adder);
        while GetSwitch(SENSOR_2, adder) == 0 && Failure_Flag == 0 && Go == 2
               Go = exist (path2go);
               pallet_status
               mainline_clear
               Network_Write;
        end
      pause(0.1)
      adderarmreset.Stop('brake', adder);
    end 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if error_loop_iteration > 0;
        for i = 1:1:error_loop_iteration
            disp('Moving Any Disturbed Pallets back Into Position')
            step_correction_reverse.SendToNXT(adder)
            step_correction_reverse.WaitFor(0,adder)
        end
        % reset flags for next time
        error_loop_iteration =0;
        unload_retry_flag = 0; 
        fault_flag = 0;
        Network_Write;
    end
    unload_state=1;
    state(size(state,2)) = 0;
    disp('Transfer of Pallet to mainline Completed Successfully.') 
    toc
    transfer_flag = 0; % put down the transfer flag to show that the transfer is completed
end
{ (c) by Mr.Old 15.10.94, ver. 1.01, last upgrade 15.10.94     }

{$X+} 
unit SBDSP;
    interface
        uses
            VOC;
        const
            On = true;
            Off = false;
        type
            Proc = procedure;
        function InitSB(IRQ: byte; BaseIO: word; DMAChannel: byte): boolean;
        function EnvironmentSet: boolean;
        function InitSBFromEnv: boolean;
        procedure ShutDownSB;
        procedure InstallHandler;
        procedure UninstallHandler;
        function ResetDSP: boolean;
        function GetDSPVersion: string;
        procedure TurnSpeakerOn;
        procedure TurnSpeakerOff;
        function GetSpeakerState: boolean;
        procedure PlaySound(Sound: PSound);
        procedure PauseSound;
        procedure ContinueSound;
        procedure BreakLoop;
        procedure SetMarkerProc(MarkerProcedure: pointer);
        procedure GetMarkerProc(var MarkerProcedure: pointer);
        var
            SoundPlaying  : boolean;
            Looping       : boolean;
            UnknownBlock  : boolean;
            UnplayedBlock : boolean;
            LastMarker    : word;
    implementation
        uses
            DOS,
            CRT,
            MemUnit;
        const
            CmdDirectDAC       = $10;
            CmdNormalDMADAC    = $14;
            Cmd2BitDMADAC      = $16;
            Cmd2BitRefDMADAC   = $17;
            CmdDirectADC       = $20;
            CmdNormalDMAADC    = $24;
            CmdSetTimeConst    = $40;
            CmdSetBlockSize    = $48;
            Cmd4BitDMADAC      = $74;
            Cmd4BitRefDMADAC   = $75;
            Cmd26BitDMADAC     = $76;
            Cmd26BitRefDMADAC  = $77;
            CmdSilenceBlock    = $80;
            CmdHighSpeedDMADAC = $91;
            CmdHighSpeedDMAADC = $99;
            CmdHaltDMA         = $D0;
            CmdSpeakerOn       = $D1;
            CmdSpeakerOff      = $D3;
            CmdGetSpeakerState = $D8;
            CmdContinueDMA     = $D4;
            CmdGetVersion      = $E1;
            DACCommands : array[0..3] of byte = (CmdNormalDMADAC, Cmd4BitDMADAC, Cmd26BitDMADAC, Cmd2BitDMADAC);
        var
            ResetPort    : word;
            ReadPort     : word;
            WritePort    : word;
            PollPort     : word;

            PICPort      : byte;
            IRQStartMask : byte;
            IRQStopMask  : byte;
            IRQIntVector : byte;
            IRQHandlerInstalled : boolean;

            DMAStartMask : byte;
            DMAStopMask  : byte;
            DMAModeReg   : byte;

            OldIntVector : pointer;
            OldExitProc  : pointer;

            MarkerProc   : pointer;
        var
            VoiceStart     : LongInt;
            CurPos         : LongInt;
            CurPageEnd     : LongInt;
            VoiceEnd       : LongInt;
            LeftToPlay     : LongInt;
            TimeConstant   : byte;
            SoundPacking   : byte;
            CurDACCommand  : byte;

            LoopStart      : PBlock;
            LoopsRemaining : word;
            EndlessLoop    : boolean;

            SilenceBlock   : boolean;

            CurBlock       : PBlock;
            NextBlock      : PBlock;

        procedure EnableInterrupts;  InLine($FB);
        procedure DisableInterrupts; InLine($FA);
        procedure WriteDSP(Value: byte);
            Inline
              (
                $8B/$16/>WritePort/
                $EC/                   {IN    AL, DX                    }
                $24/$80/               {AND   AL, 80h                   }
                $75/$FB/               {JNZ   -05                       }
                $58/                   {POP   AX                        }
                $8B/$16/>WritePort/    {MOV   DX, WritePort (Variable)  }
                $EE                    {OUT   DX, AL                    }
              );
        function ReadDSP: byte;
            Inline
              (
                $8B/$16/>PollPort/     {MOV   AL, PollPort  (Variable)  }
                $EC/                   {IN    AL, DX                    }
                $24/$80/               {AND   AL, 80h                   }
                $74/$FB/               {JZ    -05                       }
                $8B/$16/>ReadPort/     {MOV   DX, ReadPort  (Variable)  }
                $EC                    {IN    AL,DX                     }
              );
        function InitSB(IRQ: byte; BaseIO: word; DMAChannel: byte): boolean;
            const
                IRQIntNums : array[0..15] of byte =
                    ($08, $09, $0A, $0B, $0C, $0D, $0E, $0F,
                     $70, $71, $72, $73, $74, $75, $76, $77);
            var
                Success: boolean;
            begin
                if IRQ <= 7
                    then PICPort := $21
                    else PICPort := $A1;
                IRQIntVector := IRQIntNums[IRQ];
                IRQStopMask  := 1 SHL (IRQ mod 8);
                IRQStartMask := not(IRQStopMask);

                ResetPort := BaseIO + $6;
                ReadPort  := BaseIO + $A;
                WritePort := BaseIO + $C;
                PollPort  := BaseIO + $E;

                DMAStartMask := DMAChannel + $00;
                DMAStopMask  := DMAChannel + $04;
                DMAModeReg   := DMAChannel + $48;

                Success := ResetDSP;
                if Success then InstallHandler;
                InitSB := Success;
            end;
        function EnvironmentSet: boolean;
            begin
                EnvironmentSet := GetEnv('BLASTER') <> '';
            end;
        function GetSetting(BLASTER: string; Letter: char; Hex: boolean; var Value: word): boolean;
            var
                EnvStr: string;
                NumStr: string;
                ErrorCode: integer;
            begin
                EnvStr := BLASTER + ' ';
                Delete(EnvStr, 1, Pos(Letter, EnvStr));
                NumStr := Copy(EnvStr, 1, Pos(' ', EnvStr)-1);
                if Hex
                    then Val('$' + NumStr, Value, ErrorCode)
                    else Val(NumStr, Value, ErrorCode);
                if ErrorCode <> 0
                    then GetSetting := false
                    else GetSetting := true;
            end;
        function GetSettings(var BaseIO, IRQ, DMAChannel: word): boolean;
            var
                EnvStr: string;
                i: byte;
            begin
                EnvStr := GetEnv('BLASTER');
                for i := 1 to Length(EnvStr) do EnvStr[i] := UpCase(EnvStr[i]);
                GetSettings := true;
                if EnvStr = ''
                    then
                        GetSettings := false
                    else
                        begin
                            if not(GetSetting(EnvStr, 'A', true, BaseIO))
                                then GetSettings := false;
                            if not(GetSetting(EnvStr, 'I', false, IRQ))
                                then GetSettings := false;
                            if not(GetSetting(EnvStr, 'D', false, DMAChannel))
                                then GetSettings := false;
                        end;
            end;
        function InitSBFromEnv: boolean;
            var
                IRQ, BaseIO, DMAChannel: word;
            begin
                if GetSettings(BaseIO, IRQ, DMAChannel)
                    then InitSBFromEnv := InitSB(IRQ, BaseIO, DMAChannel)
                    else InitSBFromEnv := false;
            end;
        procedure ShutDownSB;
            begin
                ResetDSP;
                UninstallHandler;
            end;
        function ResetDSP: boolean;
            var
                i: byte;
            begin
                Port[ResetPort] := 1;
                Delay(1);
                Port[ResetPort] := 0;
                i := 1;
                while (ReadDSP <> $AA) and (i < 100) do
                    Inc(i);
                if i < 100
                    then ResetDSP := true
                    else ResetDSP := false;
            end;
        function GetDSPVersion: string;
            var
                MajorByte, MinorByte: byte;
                MajorStr, MinorStr: string;
            begin
                WriteDSP(CmdGetVersion);
                MajorByte := ReadDSP;   Str(MajorByte, MajorStr);
                MinorByte := ReadDSP;   Str(MinorByte, MinorStr);
                GetDSPVersion := MajorStr + '.'  + MinorStr;
            end;
        procedure TurnSpeakerOn;
            begin
                WriteDSP(CmdSpeakerOn);
            end;
        procedure TurnSpeakerOff;
            begin
                WriteDSP(CmdSpeakerOff);
            end;
        function GetSpeakerState: boolean;
            var
                SpeakerByte: byte;
            begin
                WriteDSP(CmdGetSpeakerState);
                SpeakerByte := ReadDSP;
                if SpeakerByte = 0
                    then GetSpeakerState := Off
                    else GetSpeakerState := On;
            end;
        procedure StartDMADSP;
            var
                Page: byte;
                Offset: word;
                Length: word;
                NextPageStart: LongInt;
            begin
                Page := CurPos shr 16;
                Offset := CurPos mod 65536;
                if VoiceEnd < CurPageEnd
                    then Length := LeftToPlay-1
                    else Length := CurPageEnd - CurPos;

                Inc(CurPos, LongInt(Length)+1);
                Dec(LeftToPlay, LongInt(Length)+1);
                Inc(CurPageEnd, 65536);

                WriteDSP(CmdSetTimeConst);
                WriteDSP(TimeConstant);
                Port[$0A] := DMAStopMask;
                Port[$0C] := $00;
                Port[$0B] := DMAModeReg;
                Port[$02] := Lo(Offset);
                Port[$02] := Hi(Offset);
                Port[$03] := Lo(Length);
                Port[$03] := Hi(Length);
                Port[$83] := Page;
                Port[$0A] := DMAStartMask;
                WriteDSP(CurDACCommand);
                WriteDSP(Lo(Length));
                WriteDSP(Hi(Length));
            end;
        procedure CallMarkerProc;
            begin
                if MarkerProc <> nil then Proc(MarkerProc);
            end;
        function HandleBlock(Block: PBlock): boolean;
            begin
                HandleBlock := false;
                case Block^.BlockType
                    of
                        EndBlockNum:
                            begin
                                SoundPlaying := false;
                                HandleBlock := true;
                            end;
                        VoiceBlockNum:
                            begin
                                VoiceStart := GetAbsoluteAddress(Block) + 6;
                                CurPageEnd := ((VoiceStart shr 16) shl 16) + 65536 - 1;
                                LeftToPlay := BlockSize(Block) - 6;
                                VoiceEnd := VoiceStart + LeftToPlay;
                                CurPos := VoiceStart;
                                TimeConstant := PVoiceBlock(Block)^.SR;
                                SoundPacking := PVoiceBlock(Block)^.Packing;
                                CurDACCommand := DACCommands[SoundPacking];
                                StartDMADSP;
                                HandleBlock := true;
                            end;
                        VoiceContinueBlockNum:
                            begin
                                VoiceStart := GetAbsoluteAddress(Block)+4;
                                LeftToPlay := BlockSize(Block) - 4;
                                VoiceEnd := VoiceStart + LeftToPlay;
                                CurPos := VoiceStart;
                                StartDMADSP;
                                HandleBlock := true;
                            end;
                        SilenceBlockNum:
                             begin
                                 SilenceBlock := true;
                                 WriteDSP(CmdSetTimeConst);
                                 WriteDSP(PSilenceBlock(Block)^.SR);
                                 WriteDSP(CmdSilenceBlock);
                                 WriteDSP(Lo(PSilenceBlock(Block)^.Duration+1));
                                 WriteDSP(Hi(PSilenceBlock(Block)^.Duration+1));
                                 HandleBlock := true;
                             end;
                        MarkerBlockNum:
                             begin
                                 LastMarker := PMarkerBlock(Block)^.Marker;
                                 CallMarkerProc;
                             end;
                        MessageBlockNum:
                            begin
                            end;
                        RepeatBlockNum:
                            begin
                                 LoopStart := NextBlock;
                                 LoopsRemaining := PRepeatBlock(Block)^.Count+1;
                                 if LoopsRemaining = 0
                                     then EndlessLoop := true
                                     else EndlessLoop := false;
                                 Looping := true;
                             end;
                        RepeatEndBlockNum:
                             begin
                                 if not(EndlessLoop)
                                     then
                                         begin
                                             Dec(LoopsRemaining);
                                             if LoopsRemaining = 0
                                                 then
                                                     begin
                                                         Looping := false;
                                                         Exit;
                                                     end;
                                         end;
                                 NextBlock := LoopStart;
                             end;
                        NewVoiceBlockNum:
                             begin
                                 if (PNewVoiceBlock(Block)^.Mode = NewStereo) or (PNewVoiceBlock(Block)^.BitsPerSample = 16)
                                     then
                                         UnplayedBlock := true
                                     else
                                         begin
                                             VoiceStart := GetAbsoluteAddress(Block) + 16;
                                             CurPageEnd := ((VoiceStart shr 16) shl 16) + 65536 - 1;
                                             LeftToPlay := BlockSize(Block) - 16;
                                             VoiceEnd := VoiceStart + LeftToPlay;
                                             CurPos := VoiceStart;
                                             TimeConstant := GetSRByte(PNewVoiceBlock(Block)^.SamplingRate);
                                             SoundPacking := PNewVoiceBlock(Block)^.Compression;
                                             CurDACCommand := DACCommands[SoundPacking];
                                             StartDMADSP;
                                             HandleBlock := true;
                                         end;
                             end;
                        else
                             UnknownBlock := true;
                    end;
            end;
        procedure ProcessBlocks;
            begin
                repeat
                    CurBlock := NextBlock;
                    NextBlock := FindNextBlock(pointer(CurBlock));
                until HandleBlock(CurBlock);
            end;
        procedure ClearInterrupt;
            var
                Temp: byte;
            begin
                Temp := Port[PollPort];
                Port[$20] := $20;
            end;
        procedure IntHandler; interrupt;
            begin
                if SilenceBlock
                    then
                        begin
                            SilenceBlock := false;
                            ProcessBlocks;
                        end
                    else
                        if LeftToPlay <> 0
                            then StartDMADSP
                            else ProcessBlocks;

                ClearInterrupt;
            end;
        procedure PlaySound(Sound: PSound);
            begin
                PauseSound;
                NextBlock      := PBlock(Sound);
                SoundPlaying   := true;
                Looping        := false;
                LastMarker     := 0;
                UnknownBlock   := false;
                UnplayedBlock  := false;

                LoopStart      := nil;
                LoopsRemaining := 0;
                EndlessLoop    := false;

                ProcessBlocks;
            end;
        procedure PauseSound;
            begin
                WriteDSP(CmdHaltDMA);
            end;
        procedure ContinueSound;
            begin
                WriteDSP(CmdContinueDMA);
            end;
        procedure BreakLoop;
            begin
                LoopsRemaining := 1;
                EndlessLoop := false;
            end;

        procedure StopSBIRQ;
            begin
                Port[PICPort] := Port[PICPort] OR IRQStopMask;
            end;
        procedure StartSBIRQ;
            begin
                Port[PICPort] := Port[PICPort] AND IRQStartMask;
            end;
        procedure InstallHandler;
            begin
                DisableInterrupts;
                StopSBIRQ;
                GetIntVec(IRQIntVector, OldIntVector);
                SetIntVec(IRQIntVector, @IntHandler);
                StartSBIRQ;
                EnableInterrupts;
                IRQHandlerInstalled := true;
            end;
        procedure UninstallHandler;
            begin
                DisableInterrupts;
                StopSBIRQ;
                SetIntVec(IRQIntVector, OldIntVector);
                EnableInterrupts;
                IRQHandlerInstalled := false;
            end;

        procedure SetMarkerProc(MarkerProcedure: pointer);
            begin
                MarkerProc := MarkerProcedure;
            end;
        procedure GetMarkerProc(var MarkerProcedure: pointer);
            begin
                MarkerProcedure := MarkerProc;
            end;
        procedure SBDSPExitProc; far;
            begin
                ExitProc := OldExitProc;
                ResetDSP;
                if (IRQHandlerInstalled = true) then UninstallHandler;
            end;
    begin
        MarkerProc   := nil;
        OldExitProc  := ExitProc;
        ExitProc     := @SBDSPExitProc;
        SoundPlaying := false;
    end. 
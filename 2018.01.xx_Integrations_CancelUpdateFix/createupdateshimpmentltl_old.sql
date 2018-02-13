-- =============================================
-- Author:		Ankit Patel
-- Create date: 06/21/2017
-- Description:	Insert Shipment information
-- =============================================
CREATE PROCEDURE [LTLin].[CreateUpdateShipment] 
	@CreatedBy UNIQUEIDENTIFIER,
	@ValidStart DATETIME2,
	@Shipment as LTLin.TT_Shipment READONLY, 
	@ShipmentReference as LTLin.TT_ShipmentReference READONLY,
    @OldMessageID BIGINT OUTPUT,
	@MessageID BIGINT OUTPUT 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
    SET NOCOUNT ON;
   
    DECLARE @Assert TABLE (ValidStart DATETIME2(7), ValidEnd DATETIME2(7))
	DECLARE @MagicDate DATETIME2(7) = global.GetMagicDate()
	DECLARE @ValidEnd DATETIME2(7)
	DECLARE @OperationDate DATETIME2(7) = GETDATE()
	DECLARE	@CustomerID nvarchar(10) 


	-- find earliest timeslice after this entry in case of late entry.
	SELECT @ValidEnd = COALESCE(DATEADD(NANOSECOND, -100, MIN(SS.ValidStart)), @MagicDate),
	 @OldMessageID = MAX(SS.MessageID)
	FROM LTLin.[Shipment] SS WITH (NOLOCK)
	INNER JOIN LTLin.[ShipmentReference] SR WITH (NOLOCK) ON SR.MessageID = SS.MessageID 
	--INNER JOIN @Shipment SP ON SS.ShipmentID = SP.ShipmentID
	INNER JOIN @ShipmentReference TT ON TT.ShipmentReferenceCode = SR.ShipmentReferenceCode AND TT.ShipmentReferenceValue = SR.ShipmentReferenceValue
	AND SR.ShipmentReferenceCode = 'BM'  AND SS.RowDeleted = @MagicDate AND SS.ValidStart < @ValidStart



    -- Insert statements for procedure here
	INSERT INTO LTLin.[Shipment]
			   ([ShipmentID]
			   ,[CustomerID]
			   ,[SCAC]
			   ,[ModeID]
			   ,[Terms]
			   ,[RecordType]
			   ,[HazMat]
			   ,[TransmitDate]
			   ,[ActivityDate]
			   ,[DeliveryDate]
			   ,[DeliveryByDate]
			   ,[PickUpByDate]
			   ,[PickupReadyByDate]
			   ,[RequestedDeliveryByDate]
			   ,[CarrierTotal]
			   ,[Distance]
			   ,[NumberOfPallets]
			   ,[PalletStackAble]
			   ,[TotalWeight]
			   ,[TotalWeightUnitCode]
			   ,[AccessorialService]
			   ,[GuaranteedDelivery]
			   ,[NotesInternal]
			   ,[NotesExternal]
			   ,[TrailerNumber]
			   ,[EquipmentTypeCode]
			   ,[EquipmentTarpCode]
			   ,[EquipmentLengthCode]
			   ,[EquipmentAccessorialCode]
			   ,[EquipmentNotes]
			   ,[ValidEnd]			   		   
			   ,[RowCreated]
      		   ,[RowDeleted]
			   ,[RowCreatedBy]	
			   )

 	    OUTPUT inserted.ValidStart, inserted.ValidEnd INTO @Assert

 		 SELECT [ShipmentID]
		       ,[CustomerID]
			   ,[SCAC]
			   ,[ModeID]
			   ,[Terms]
			   ,[RecordType]
			   ,[HazMat]
			   ,[TransmitDate]
			   ,[ActivityDate]
			   ,[DeliveryDate]
			   ,[DeliveryByDate]
			   ,[PickUpByDate]
			   ,[PickupReadyByDate]
			   ,[RequestedDeliveryByDate]
			   ,[CarrierTotal]
			   ,[Distance]
			   ,[NumberOfPallets]
			   ,[PalletStackAble]
			   ,[TotalWeight]
			   ,[TotalWeightUnitCode]
			   ,[AccessorialService]
			   ,[GuaranteedDelivery]
			   ,[NotesInternal]
			   ,[NotesExternal]
			   ,[TrailerNumber]
			   ,[EquipmentTypeCode]
			   ,[EquipmentTarpCode]
			   ,[EquipmentLengthCode]
			   ,[EquipmentAccessorialCode]
			   ,[EquipmentNotes]
			   ,@MagicDate		   
			   ,@OperationDate
			   ,@MagicDate
			   ,@CreatedBy
		  FROM @Shipment

  SET @MessageID = SCOPE_IDENTITY() --IDENT_CURRENT('LTLin.[LTLShipment]');


	IF (@ValidEnd <> @MagicDate) BEGIN
		-- unfortunately necessary to check for overlap.... would be an error to allow
		IF (1 < (SELECT COUNT(ValidStart) FROM @Assert WHERE ValidEnd > @ValidStart AND ValidStart < @ValidEnd))
		BEGIN
			RAISERROR('Assertion Failed', 16, 1)
		END
	END 
    -- END ASSERT: after clipping

  
    UPDATE SS
	SET SS.[ValidEnd] = @OperationDate, SS.[RowDeleted] = @OperationDate, SS.[RowDeletedBy] = @CreatedBy
	FROM LTLin.[Shipment] AS SS 
    WHERE  SS.[MessageID] = @OldMessageID 
	AND SS.[ValidStart] > @ValidEnd
	AND SS.[ValidEnd] = @MagicDate
	AND SS.[RowCreated] <> @OperationDate
    AND SS.[RowDeleted] = @MagicDate  
END
 
SET STATISTICS IO ON 

DECLARE @OriginZip VARCHAR(5) = '28625', 
@DestinationZip VARCHAR(5) = '28144', 
@EffectiveDate DATETIME = '2017-07-23 00:00:00.000',
@FileImportID BIGINT 



    SELECT @FileImportID = fi.FileImportId
    FROM
        [History].[FileImport] [fi]
    WHERE
        [fi].[OriginZip] = @OriginZip
    AND
        [fi].[DestinationZip] = @DestinationZip
    AND
        [fi].[EffectiveDate] = @EffectiveDate

SELECT FileImportId ,
       EffectiveDate ,
       OriginZip ,
       DestinationZip ,
       RateIndicator ,
       MaxCircleIndicator ,
       RPM2Amount ,
       RPM4Amount ,
       RPM7Amount ,
       RPM10Amount ,
       RPM12Amount ,
       FR2Amount ,
       FR4Amount ,
       FR7Amount ,
       FR10Amount ,
       FR12Amount ,
       MinCircleIndicator ,
       PctFR8Amount ,
       PctFR25Amount ,
       PctFR50Amount ,
       PctFR75Amount ,
       PctFR92Amount ,
       PctRPM8Amount ,
       PctRPM25Amount ,
       PctRPM50Amount ,
       PctRPM75Amount ,
       PctRPM92Amount ,
       CreatedDate ,
       ImportDate
FROM History.FileImport
WHERE FileImportId = @FileImportID
//
//  CoreDataManager.h
//  Carat
//
//  Created by Anand Padmanabha Iyer on 11/5/11.
//  Copyright (c) 2011 UC Berkeley. All rights reserved.
//

#ifndef Carat_CoreDataManager_h
#define Carat_CoreDataManager_h

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <mach/mach_host.h>
#import "Globals.h"
#import "UIDeviceProc.h"
#import "CoreDataProcessInfo.h"
#import "CoreDataSample.h"
#import "CoreDataAppReport.h"
#import "CoreDataDetail.h"
#import "CoreDataMainReport.h"
#import "CoreDataSubReport.h"
#import "CoreDataRegistration.h"
#import "CommunicationManager.h"

#import "ActionObject.h"

@interface CoreDataManager : NSObject 
{
    NSDate * LastUpdatedDate;
    DetailScreenReport * JScoreInfo;
    DetailScreenReport * JScoreInfoWithout;
    DetailScreenReport * OSInfo;
    DetailScreenReport * OSInfoWithout;
    DetailScreenReport * ModelInfo;
    DetailScreenReport * ModelInfoWithout;
    DetailScreenReport * SimilarAppsInfo;
    DetailScreenReport * SimilarAppsInfoWithout;
    NSArray * ChangesSinceLastWeek;
    NSURLConnection *connection;
    NSMutableData *receivedData;
    NSMutableDictionary *processInfos;
}

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSDate * LastUpdatedDate;
@property (nonatomic, retain) DetailScreenReport * JScoreInfo;
@property (nonatomic, retain) DetailScreenReport * JScoreInfoWithout;
@property (nonatomic, retain) DetailScreenReport * OSInfo;
@property (nonatomic, retain) DetailScreenReport * OSInfoWithout;
@property (nonatomic, retain) DetailScreenReport * ModelInfo;
@property (nonatomic, retain) DetailScreenReport * ModelInfoWithout;
@property (nonatomic, retain) DetailScreenReport * SimilarAppsInfo;
@property (nonatomic, retain) DetailScreenReport * SimilarAppsInfoWithout;
@property (nonatomic, retain) NSArray * ChangesSinceLastWeek;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSLock *lockReportSync;
@property (nonatomic, retain) NSString * daemonsFilePath;

+ (id) instance;
- (void) generateSaveRegistration;
- (void) sampleNow : (NSString *) triggeredBy;
- (void) checkConnectivityAndSendStoredDataToServer;
- (void) updateLocalReportsFromServer;
- (void) updateSamplesSentCount;
- (NSURL *) applicationDocumentsDirectory;
- (NSDate *) getLastReportUpdateTimestamp; 
- (double) secondsSinceLastUpdate;
- (HogBugReport *) getHogs : (BOOL) filterNonRunning withoutHidden : (BOOL) filterHidden;
- (HogBugReport *) getBugs : (BOOL) filterNonRunning withoutHidden : (BOOL) filterHidden;
- (double) getJScore;
- (NSString *) getJScoreString;
- (NSInteger) getSampleSent;
- (DetailScreenReport *) getJScoreInfo : (BOOL) with;
- (DetailScreenReport *) getOSInfo : (BOOL) with;
- (DetailScreenReport *) getModelInfo : (BOOL) with;
- (DetailScreenReport *) getSimilarAppsInfo : (BOOL) with;
- (NSArray *) getChangeSinceLastWeek;
- (Sample *) getSample;
- (NSString *) getReportUpdateStatus;
- (void) wipeDB;

//CPU Usage Data
- (void) setCPUData:(float)used total:(float) total;

-(ActionObject*)createActionObjectFromDetailScreenReport:(NSString *)actText actType:(ActionType)actTyp;
-(NSMutableArray *)getBugsActionList:(BOOL)getBugs withoutHidden:(BOOL)withoutHidden actText:(NSString *)actText actType:(ActionType)actType;
-(NSMutableArray *)getHogsActionList:(BOOL)getHogs withoutHidden:(BOOL)withoutHidden actText:(NSString *)actText actType:(ActionType)actType;
-(NSMutableArray *)getHogsBugsActionList:(NSArray *)list actText:(NSString *)actText actType:(ActionType)actTyp;
-(NSInteger)calcBenefit: (double)expVal expValWithout:(double)expValWithout;
-(NSInteger)calcMaxBenefit:(double)expVal expValWithout:(double)expValWithout errWithout:(double)errWithout err:(double)err;

@end

#endif

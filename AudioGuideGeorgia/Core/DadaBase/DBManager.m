//------------------------------------------------------------------------------
// PROJECT:  TKT.GE
// VERSION:  1.0.1
// COPYRIGHT © 2016 Lemondo Entertainment. All rights reserved.
//************************************************************************************
//* REPRODUCTION OF ANY KIND, IN WHOLE OR IN PART IN ANY FORM IS STRICTLY PROHIBITED *
//************************************************************************************
// DESCRIPTION:   Tkt.ge Database Manager Class
// FILE NAME:     DB_Manager.m
// AUTHOR:        Rezo Mesarkishvili ( rezo@lemondo.com )
// LAST REVISION: 25 October 2016 by RM
//------------------------------------------------------------------------------

#import <sqlite3.h>

#import "DBManager.h"

#import "SharedPreferenceManager.h"
#import "PagesModel.h"
#import "RestaurantsModel.h"
#import "ShopsModel.h"
#import "FestivalsModel.h"
#import "ToursModel.h"
#import "SightModel.h"
#import "FilterModel.h"
#import "LanguageManager.h"

static NSString * const selecPages = @"SELECT * FROM 'PracticalInfo'";
static NSString * const deletePages = @"DELETE FROM 'PracticalInfo'";
static NSString * const deletePagesWithID = @"DELETE FROM 'PracticalInfo' WHERE id = %d";
static NSString * const insertPages = @"INSERT INTO 'PracticalInfo' ( 'id', 'title', 'description', 'imagesfirst' , 'date') VALUES ('%ld', '%@', '%@', '%@', '%f')";

static NSString * const selectRestaurants = @"SELECT * FROM 'Restaurants'";
static NSString * const deleteRestaurants = @"DELETE FROM 'Restaurants'";
static NSString * const deleteRestaurantsWithID = @"DELETE FROM 'Restaurants' WHERE sightid = %d";
static NSString * const insertRestaurants = @"INSERT INTO 'Restaurants' ( 'imagesfirst', 'sightdescription', 'sightid', 'sightlat' , 'sightlng' , 'sighttitle' , 'address' , 'resttype' , 'weburl' , 'contact' , 'restkind' , 'date') VALUES ('%@', '%@', '%ld', '%f', '%f' ,'%@','%@','%@','%@','%@','%@','%f')";

static NSString * const selectImages = @"SELECT * FROM 'Images' WHERE tabletype = '%@' AND objectid = '%d'";
static NSString * const deleteImages = @"DELETE FROM 'Images' WHERE tabletype = '%@'";
static NSString * const deleteImagesWithID = @"DELETE FROM 'Images' WHERE tabletype = '%@' AND objectid = '%d'";
static NSString * const insertImages = @"INSERT INTO 'Images' ( 'tabletype', 'imageurl',objectid) VALUES ('%@', '%@','%d')";

static NSString * const selectShops = @"SELECT * FROM 'Shops'";
static NSString * const deleteShops = @"DELETE FROM 'Shops'";
static NSString * const deleteShopsWithID = @"DELETE FROM 'Shops' WHERE sightid = %d";
static NSString * const insertShops = @"INSERT INTO 'Shops' ( 'imagesfirst', 'sightdescription', 'sightid', 'sightlat' , 'sightlng' , 'sighttitle' , 'contact' , 'address' , 'weburl' , 'typeshop' , 'date') VALUES ('%@', '%@', '%ld', '%f', '%f' ,'%@','%@','%@','%@','%@','%f')";

static NSString * const selectFestivals = @"SELECT * FROM 'Festivals'";
static NSString * const deleteFestivals = @"DELETE FROM 'Festivals'";
static NSString * const insertFestivals = @"INSERT INTO 'Festivals' ( 'imagesfirst', 'sightdescription', 'sightid', 'sightlat' , 'sightlng' , 'sighttitle' , 'address' , 'contact' , 'typefestival' , 'venuename' , 'eventdate') VALUES ('%@', '%@', '%ld', '%f', '%f' ,'%@','%@','%@','%@','%@','%f')";


static NSString * const selectTourUsers = @"SELECT * FROM 'tourusers' WHERE tourid = '%d'";
static NSString * const insertTourUsers = @"INSERT INTO 'tourusers' ( 'tourid', 'usertoken') VALUES ('%d', '%@')";

static NSString * const selectTours = @"SELECT * FROM 'Tours'";
static NSString * const selectToursWithID = @"SELECT * FROM 'Tours' WHERE toursid = '%d'";
static NSString * const deleteTours = @"DELETE FROM 'Tours'";
static NSString * const deleteToursWithID = @"DELETE FROM 'Tours' WHERE toursid = '%d'";
static NSString * const insertTours = @"INSERT INTO 'Tours' ( 'toursid', 'polylinestr', 'tourtotalprice', 'cityid' , 'distance' , 'duration' , 'tourtitle' , 'tourdescription' , 'breaktip' , 'notes' , 'finish' , 'start' , 'date' , 'tourlive' , 'ispopular', 'receptstring','tourfree','tourraiting') VALUES ('%d', '%@', '%@', '%d', '%f' ,'%f','%@','%@','%@','%@','%@','%@',%f,%d,%d,'%@',%d,%ld)";
static NSString * const updateTpurLive = @"UPDATE 'Tours' SET tourlive = '%d', receptstring = '%@' WHERE toursid = '%d'";
static NSString * const updateTourNoLive = @"UPDATE 'Tours' SET tourlive = '0' WHERE  receptstring = '(null)'";
static NSString * const updateTourDelete = @"UPDATE 'Tours' SET isdeleted = '%d',receptstring = '%@' WHERE toursid = '%d'";
static NSString * const updateAllTourDelete = @"UPDATE 'Tours' SET isdeleted = '%d',tourlive = '%d' WHERE tourlive = '%d'";
static NSString * const updateAllTourToDelete = @"UPDATE 'Tours' SET isdeleted = '%d'";
static NSString * const updateTourRestore = @"UPDATE 'Tours' SET isdeleted = '%d', receptstring = '%@' WHERE toursid = '%d'";
static NSString * const submitTourRaview = @"UPDATE 'Tours' SET tourraiting = '%ld' , tourisrait = '%d' WHERE toursid = '%d'";
static NSString * const updateTour = @"UPDATE 'Tours' SET polylinestr = '%@' , tourtotalprice = '%@' , cityid = '%d' , distance = '%f' , duration = '%f' , tourtitle = '%@' , tourdescription = '%@' , breaktip = '%@' , notes = '%@' , finish = '%@' , start = '%@' , date = '%f' , ispopular = '%d' , tourfree = '%d', tourraiting = '%ld' WHERE toursid = '%d'";

static NSString * const selectSights = @"SELECT * FROM 'Sights'";
static NSString * const selectSightsWithID = @"SELECT * FROM 'Sights' WHERE sightid = '%d'";
static NSString * const deleteSights = @"DELETE FROM 'Sights'";
static NSString * const deleteSightsWithID = @"DELETE FROM 'Sights' WHERE sightid = '%d'";
static NSString * const insertSights = @"INSERT INTO 'Sights' ( 'imagesfirst', 'sightdescription', 'sightid', 'sightlat' , 'sightlng' , 'sighttitle' , 'sightprice' , 'date','audio_en' , 'audioName_en' , 'localaudio', 'mustsee', 'city_id', 'needupdate', 'auidofilememory', 'sightispass', 'sightrecept') VALUES ('%@', '%@', '%d', '%f', '%f' ,'%@','%lu','%f','%@','%@' , '%@','%d', '%d','%d','%lu','%d','%@')";
static NSString * const updateSight = @"UPDATE 'Sights' SET sightprice = '%d' WHERE sightid = '%d'";
static NSString * const updateSightToPass = @"UPDATE 'Sights' SET sightispass = '%d' WHERE sightid = '%d'";

static NSString * const updateHoleSight = @"UPDATE 'Sights' SET imagesfirst = '%@' , sightdescription = '%@' , sightid = '%d' , sightlat = '%f' , sightlng = '%f' , sighttitle = '%@' , date = '%f' , audio_en = '%@' , audioName_en = '%@' , mustsee = '%d' , city_id = '%d' , sightprice = '%lu' , needupdate = '%d', auidofilememory = '%lu'  WHERE sightid = '%d'";
static NSString * const updateSightLocalAudi = @"UPDATE 'Sights' SET localaudio = '%@', needupdate = '%d', sightrecept = '%@' WHERE sightid = '%d'";

static NSString * const selectToursSights = @"SELECT * FROM 'ToursSights' WHERE toursid = '%d' AND type = '%@'";
static NSString * const selectSightsTours = @"SELECT * FROM 'ToursSights' WHERE sightsid = '%d' AND type = '%@'";
static NSString * const deleteToursSights = @"DELETE FROM 'ToursSights' WHERE toursid = '%d' AND type = '%@'";
static NSString * const deleteSightsTours = @"DELETE FROM 'ToursSights' WHERE sightsid = '%d' AND type = '%@'";
static NSString * const insertToursSights = @"INSERT INTO 'ToursSights' ( 'toursid', 'sightsid' , 'type') VALUES ('%d', '%d', '%@')";

static NSString * const selectTourFilter = @"SELECT * FROM 'TourFilters'";
static NSString * const selectTourFilterWithID = @"SELECT * FROM 'TourFilters' WHERE id = '%d'";
static NSString * const deleteTourFilter = @"DELETE FROM 'TourFilters'";
static NSString * const deleteTourFilterWithID = @"DELETE FROM 'TourFilters' WHERE id = '%d'";
static NSString * const insertTourFilter = @"INSERT INTO 'TourFilters' ( 'id', 'name', 'date') VALUES ('%d', '%@', '%f')";

static NSString * const selectSightFilter = @"SELECT * FROM 'SightFilters'";
static NSString * const selectSightFilterWithID = @"SELECT * FROM 'SightFilters' WHERE id = '%d'";
static NSString * const deleteSightFilter = @"DELETE FROM 'SightFilters'";
static NSString * const deleteSightFilterWithID = @"DELETE FROM 'SightFilters' WHERE id = '%d'";
static NSString * const insertSightFilter = @"INSERT INTO 'SightFilters' ( 'id', 'name', 'date') VALUES ('%d', '%@', '%f')";


static NSString * const selectSightFilterWithParams = @"SELECT * FROM 'FilterHelper' WHERE type = '%@' AND sightid = '%d'";
static NSString * const insertSightFilterWithParams = @"INSERT INTO 'FilterHelper' ( 'type', 'sightid', 'filterid') VALUES ('%@', '%d', '%d')";
static NSString * const deleteSightFilterWithParams = @"DELETE FROM 'FilterHelper' WHERE type = '%@' AND sightid = '%d'";

static NSString * const selectCity = @"SELECT * FROM 'City'";
static NSString * const selectCityWithId = @"SELECT * FROM 'City' WHERE cityid = '%d'";
static NSString * const deleteCity = @"DELETE FROM 'City'";
static NSString * const deleteCityWithID = @"DELETE FROM 'City' WHERE cityid = %d";
static NSString * const insertCity = @"INSERT INTO 'City' ( 'cityid', 'citytitle', 'keywords', 'date' , 'imagesfirst', 'priority' , 'north', 'south', 'east', 'west') VALUES ('%d', '%@', '%@', '%f', '%@', '%d', '%f', '%f','%f',%f)";

@interface DBManager ()
{
    sqlite3 * tktDB;
    BOOL      dbIsOK;
}

@end

@implementation DBManager

#pragma mark - INITIALIZATION

// ------------------------------------------------------/ sharedInstance /-----
+ (id) sharedInstance
{
    static DBManager * sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken,^
                  {
                      sharedInstance = [[DBManager alloc] init];
                  });
    
    return sharedInstance;
}

// ----------------------------------------------------------------/ init /-----
- (id) init
{
    if ( self = [super init] )
    {
        tktDB  = nil;
        dbIsOK = [self openDatabase];
    }
    return self;
}

// -------------------------------------------------------------/ dealloc /-----
- (void) dealloc
{
    [self closeDatabase];
    
#ifdef DEBUG_LOG
    NSLog(@"DBManager::dealloc");
#endif
}

// --------------------------------------------------------/ openDatabase /-----
- (BOOL) openDatabase
{
    NSArray  * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDir = [paths objectAtIndex:0];
    NSString *languageStr = [[LanguageManager sharedManager] getSelectedLanguage];
    NSString *dbName = [NSString stringWithFormat:@"AudioGuide_%@.db",languageStr];
    NSString * dbPath = [documentsDir stringByAppendingPathComponent:dbName];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    if ( ! [fileManager fileExistsAtPath:dbPath] )
    {
        NSString *dbNameFile = [NSString stringWithFormat:@"AudioGuide_%@",languageStr];
        
        NSString * dbPathOriginal = [[NSBundle mainBundle] pathForResource:dbNameFile ofType:@"db"];
        NSError * error = nil;
        if ( ! [fileManager copyItemAtPath:dbPathOriginal toPath:dbPath error:&error] )
        {
            [self logError:@"Failed to copy original DB to: \"%@\"", dbPath];
            return NO;
        }
    }
    
    NSLog(@"DBPath=%@",dbPath);
    
    int result = sqlite3_open ( [dbPath UTF8String], & tktDB );
    return ( result == SQLITE_OK );
}

// -------------------------------------------------------/ closeDatabase /-----
- (void) closeDatabase
{
    if ( tktDB )
    {
        sqlite3_close ( tktDB );
    }
}

// ------------------------------------------------------------/ logError /-----
- (void) logError: (NSString *) formatString, ...
{
#ifdef DEBUG_LOG
    
    NSString * logRecord;
    
    va_list args;
    va_start(args, formatString);
    logRecord = [[NSString alloc] initWithFormat:formatString arguments:args];
    va_end(args);
    
    NSLog(@"%@",logRecord);
    
#endif
}

// ----------------------------------------------------------/ logDBError /-----
- (void) logDBError:(int) errorCode
{
#ifdef DEBUG_LOG
    
    const char * sql_error = sqlite3_errmsg (tktDB);
    [self logError:@"sqlite error %d. %@", errorCode, [NSString stringWithUTF8String:sql_error]];
    
#endif
}

#pragma mark - Info Pages

-(void)setInfoPage:(NSArray<PagesModel*>*)pages needDelete:(BOOL)delete{
    if ( ! dbIsOK )
    {
        return;
    }
    if (delete) {
        [self deleteAllPages];
    }else{
        for ( PagesModel * shop in pages )
        {
            [self deletePages:[shop.pageID intValue]];
        }
    }
    for ( PagesModel * page in pages )
    {
        sqlite3_stmt * insertStatement;
        NSString *descriptionStr =  [page.pageDescription stringByReplacingOccurrencesOfString:@ "'" withString: @"''"];
        
        NSString * insertCategory = [NSString stringWithFormat:insertPages, (long)[page.pageID integerValue],
                                     page.pageTitle,
                                     descriptionStr,
                                     page.imagesFirst,
                                     [page.date timeIntervalSince1970]
                                     ];
        int result = sqlite3_prepare_v2 ( tktDB, [insertCategory UTF8String], -1, & insertStatement, NULL );
        if ( result == SQLITE_OK )
        {
            result = sqlite3_step (insertStatement);
            if ( result != SQLITE_DONE )
            {
                [self logError:@"sqlite3_step failed for \"insertCategory\""];
                [self logDBError:result];
            }
        }
        else
        {
            [self logError:@"sqlite3_prepare_v2 failed for \"insertCategory\""];
            [self logDBError:result];
        }
        sqlite3_finalize ( insertStatement );
    }
}
-(void)getPages:(void (^)(NSArray<PagesModel *> *))handler{
    if ( ! dbIsOK )
    {
        handler(nil);
        return;
    }
    sqlite3_stmt * selectStatement;
    int result = sqlite3_prepare_v2 ( tktDB, [selecPages UTF8String], -1, & selectStatement, NULL );
    if ( result != SQLITE_OK )
    {
        [self logError:@"sqlite3_prepare_v2 failed for \"selectCategories\" with return code %d",result];
        handler (nil);
    }
    
    NSMutableArray * dbOrders = [[NSMutableArray alloc] init];
    
    while ( sqlite3_step ( selectStatement ) == SQLITE_ROW )
    {
        int  pageID = (int)    sqlite3_column_int  ( selectStatement, 0 );
        char * pageTitle       = (char*)    sqlite3_column_text  ( selectStatement, 1 );
        char * pageDescription = (char*)    sqlite3_column_text  ( selectStatement, 2 );
        char * imagesFirst = (char*)    sqlite3_column_text  ( selectStatement, 3 );
        double date = (double) sqlite3_column_double( selectStatement, 4);
        PagesModel * pages = [[PagesModel alloc] init];
        pages.pageID = [NSNumber numberWithInteger:pageID];
        pages.pageTitle = [NSString stringWithString:[NSString stringWithUTF8String:pageTitle]];
        pages.pageDescription = [NSString stringWithString:[NSString stringWithUTF8String:pageDescription]];
        pages.imagesFirst = [NSString stringWithString:[NSString stringWithUTF8String:imagesFirst]];
        pages.date = [NSDate dateWithTimeIntervalSince1970:date];
        [dbOrders addObject:pages];
    }
    sqlite3_finalize ( selectStatement );
    
    if ( dbOrders.count )
    {
        handler ( dbOrders );
    }else{
        handler (nil);
    }
    
}
-(void)deleteAllPages{
    if ( ! dbIsOK )
    {
        return;
    }
    
    sqlite3_stmt * deleteStatement;
    int result = sqlite3_prepare_v2 ( tktDB, [deletePages UTF8String], -1, & deleteStatement, NULL );
    
    if ( result != SQLITE_OK )
    {
        [self logError:@"sqlite3_prepare_v2 failed for \"deleteCategories\" with return code %d",result];
        return;
    }
    
    result = sqlite3_step (deleteStatement);
    if ( result != SQLITE_DONE )
    {
        [self logError:@"sqlite3_step failed for \"deleteCategories\" with return code %d",result];
    }
    sqlite3_finalize ( deleteStatement );
}
-(void)deletePages:(int)pageID{
    if ( ! dbIsOK )
    {
        return;
    }
    
    sqlite3_stmt * deleteStatement;
    int result = sqlite3_prepare_v2 ( tktDB, [[NSString stringWithFormat:deletePagesWithID,pageID]  UTF8String], -1, & deleteStatement, NULL );
    
    if ( result != SQLITE_OK )
    {
        [self logError:@"sqlite3_prepare_v2 failed for \"deleteCategories\" with return code %d",result];
        return;
    }
    
    result = sqlite3_step (deleteStatement);
    if ( result != SQLITE_DONE )
    {
        [self logError:@"sqlite3_step failed for \"deleteCategories\" with return code %d",result];
    }
    sqlite3_finalize ( deleteStatement );
}
#pragma mark - Restaurant

-(void)setRestaurants:(NSArray<RestaurantsModel*>*)restaurant needDelete:(BOOL)delete{
    if ( ! dbIsOK )
    {
        return;
    }
    if (delete) {
        [self deleteAllRestaurants];
    }else{
        for ( RestaurantsModel * shop in restaurant )
        {
            [self deleteRestaurants:[shop.sightID intValue]];
        }
        
    }
    for ( RestaurantsModel * page in restaurant )
    {
        sqlite3_stmt * insertStatement;
        NSString *descriptionStr =  [page.sightDescription stringByReplacingOccurrencesOfString:@ "'" withString: @"''"];
        NSString * insertCategory = [NSString stringWithFormat:insertRestaurants, page.imagesFirst,
                                     descriptionStr,
                                     (long)[page.sightID integerValue],
                                     [page.sightLat doubleValue],
                                     [page.sightLng doubleValue],
                                     page.sightTitle,
                                     page.address,
                                     page.restType,
                                     page.webURL,
                                     page.contact,
                                     page.restKind,
                                     [page.date timeIntervalSince1970]
                                     ];
        int result = sqlite3_prepare_v2 ( tktDB, [insertCategory UTF8String], -1, & insertStatement, NULL );
        if ( result == SQLITE_OK )
        {
            result = sqlite3_step (insertStatement);
            if ( result != SQLITE_DONE )
            {
                [self logError:@"sqlite3_step failed for \"insertCategory\""];
                [self logDBError:result];
            }
        }
        else
        {
            [self logError:@"sqlite3_prepare_v2 failed for \"insertCategory\""];
            [self logDBError:result];
        }
        sqlite3_finalize ( insertStatement );
        
        
        for (int i= 0; i<page.imagesArray.count; i++) {
            [self insertImages:@"restaurant" withUrl:page.imagesArray[i] withID:page.sightID];
        }
    }
}
-(void)selectRestaurant:(void (^)(NSArray<RestaurantsModel *> *))handler{
    if ( ! dbIsOK )
    {
        handler(nil);
        return;
    }
    sqlite3_stmt * selectStatement;
    int result = sqlite3_prepare_v2 ( tktDB, [selectRestaurants UTF8String], -1, & selectStatement, NULL );
    if ( result != SQLITE_OK )
    {
        [self logError:@"sqlite3_prepare_v2 failed for \"selectCategories\" with return code %d",result];
        handler (nil);
    }
    
    NSMutableArray * dbOrders = [[NSMutableArray alloc] init];
    
    while ( sqlite3_step ( selectStatement ) == SQLITE_ROW )
    {
        char * imagesfirst = (char*)    sqlite3_column_text  ( selectStatement, 0 );
        char * sightdescription       = (char*)    sqlite3_column_text  ( selectStatement, 1 );
        int    sightid = (int)    sqlite3_column_int  ( selectStatement, 2 );
        double  sightlat = (double)    sqlite3_column_double  ( selectStatement, 3 );
        double  sightlng = (double)    sqlite3_column_double  ( selectStatement, 4 );
        char *  sighttitle = (char*)    sqlite3_column_text  ( selectStatement, 5 );
        char *  address = (char*)    sqlite3_column_text  ( selectStatement, 6 );
        char *  resttype = (char*)    sqlite3_column_text  ( selectStatement, 7 );
        char*  weburl = (char*)    sqlite3_column_text  ( selectStatement, 8 );
        char*  contact = (char*)    sqlite3_column_text  ( selectStatement, 9 );
        char*  restkind = (char*)    sqlite3_column_text  ( selectStatement, 10 );
        double date = (double) sqlite3_column_double (selectStatement, 11);
        RestaurantsModel * restaurant = [[RestaurantsModel alloc] init];
        restaurant.imagesFirst = [NSString stringWithString:[NSString stringWithUTF8String:imagesfirst]];
        restaurant.sightDescription = [NSString stringWithString:[NSString stringWithUTF8String:sightdescription]];
        restaurant.sightID = [NSNumber numberWithInt:sightid];
        restaurant.sightLat = [NSNumber numberWithFloat:sightlat];
        restaurant.sightLng = [NSNumber numberWithFloat:sightlng];
        restaurant.sightTitle = [NSString stringWithString:[NSString stringWithUTF8String:sighttitle]];
        restaurant.webURL = [NSString stringWithString:[NSString stringWithUTF8String:weburl]];
        restaurant.contact = [NSString stringWithString:[NSString stringWithUTF8String:contact]];
        restaurant.restKind = [NSString stringWithString:[NSString stringWithUTF8String:restkind]];
        restaurant.address = [NSString stringWithString:[NSString stringWithUTF8String:address]];
        restaurant.restType = [NSString stringWithString:[NSString stringWithUTF8String:resttype]];
        restaurant.date = [NSDate dateWithTimeIntervalSince1970:date];
        [self selectImageByType:@"restaurant" andObjID:restaurant.sightID withHandle:^(NSArray<NSString *> *images) {
            restaurant.imagesArray = [[NSMutableArray alloc] initWithArray:images];
        }];
        
        [dbOrders addObject:restaurant];
    }
    sqlite3_finalize ( selectStatement );
    
    if ( dbOrders.count )
    {
        handler ( dbOrders );
    }else{
        handler (nil);
    }
}
-(void)deleteAllRestaurants{
    if ( ! dbIsOK )
    {
        return;
    }
    
    sqlite3_stmt * deleteStatement;
    int result = sqlite3_prepare_v2 ( tktDB, [deleteRestaurants UTF8String], -1, & deleteStatement, NULL );
    
    if ( result != SQLITE_OK )
    {
        [self logError:@"sqlite3_prepare_v2 failed for \"deleteCategories\" with return code %d",result];
        return;
    }
    
    result = sqlite3_step (deleteStatement);
    if ( result != SQLITE_DONE )
    {
        [self logError:@"sqlite3_step failed for \"deleteCategories\" with return code %d",result];
    }
    sqlite3_finalize ( deleteStatement );
    [self deleteImages:@"restaurant"];
}
-(void)deleteRestaurants:(int)restID{
    if ( ! dbIsOK )
    {
        return;
    }
    
    sqlite3_stmt * deleteStatement;
    int result = sqlite3_prepare_v2 ( tktDB, [[NSString stringWithFormat:deleteRestaurantsWithID,restID] UTF8String], -1, & deleteStatement, NULL );
    
    if ( result != SQLITE_OK )
    {
        [self logError:@"sqlite3_prepare_v2 failed for \"deleteCategories\" with return code %d",result];
        return;
    }
    
    result = sqlite3_step (deleteStatement);
    if ( result != SQLITE_DONE )
    {
        [self logError:@"sqlite3_step failed for \"deleteCategories\" with return code %d",result];
    }
    sqlite3_finalize ( deleteStatement );
    [self deleteImages:@"restaurant" withID:restID];
}
#pragma mark - Shops

-(void)setShops:(NSArray<ShopsModel*>*)shops needDelete:(BOOL)delete{
    if ( ! dbIsOK )
    {
        return;
    }
    if (delete) {
        [self deleteAllShops];
    }else{
        for ( ShopsModel * shop in shops )
        {
            [self deleteShops:[shop.sightID intValue]];
        }
    }
    for ( ShopsModel * shop in shops )
    {
        sqlite3_stmt * insertStatement;
        NSString *descriptionStr =  [shop.sightDescription stringByReplacingOccurrencesOfString:@ "'" withString: @"''"];
        NSString * insertCategory = [NSString stringWithFormat:insertShops, shop.imagesFirst,
                                     descriptionStr,
                                     (long)[shop.sightID integerValue],
                                     [shop.sightLat doubleValue],
                                     [shop.sightLng doubleValue],
                                     shop.sightTitle,
                                     shop.contact,
                                     shop.address,
                                     shop.webURL,
                                     shop.typeShop,
                                     [shop.date timeIntervalSince1970]
                                     ];
        int result = sqlite3_prepare_v2 ( tktDB, [insertCategory UTF8String], -1, & insertStatement, NULL );
        if ( result == SQLITE_OK )
        {
            result = sqlite3_step (insertStatement);
            if ( result != SQLITE_DONE )
            {
                [self logError:@"sqlite3_step failed for \"insertCategory\""];
                [self logDBError:result];
            }
        }
        else
        {
            [self logError:@"sqlite3_prepare_v2 failed for \"insertCategory\""];
            [self logDBError:result];
        }
        sqlite3_finalize ( insertStatement );
        for (int i= 0; i<shop.imagesArray.count; i++) {
            [self insertImages:@"shops" withUrl:shop.imagesArray[i] withID:shop.sightID];
        }
    }
}
-(void)selectShops:(void (^)(NSArray<ShopsModel *> *))handler{
    if ( ! dbIsOK )
    {
        handler(nil);
        return;
    }
    sqlite3_stmt * selectStatement;
    int result = sqlite3_prepare_v2 ( tktDB, [selectShops UTF8String], -1, & selectStatement, NULL );
    if ( result != SQLITE_OK )
    {
        [self logError:@"sqlite3_prepare_v2 failed for \"selectCategories\" with return code %d",result];
        handler (nil);
    }
    
    NSMutableArray * dbOrders = [[NSMutableArray alloc] init];
    
    while ( sqlite3_step ( selectStatement ) == SQLITE_ROW )
    {
        char * imagesfirst = (char*)    sqlite3_column_text  ( selectStatement, 0 );
        char * sightdescription       = (char*)    sqlite3_column_text  ( selectStatement, 1 );
        int    sightid = (int)    sqlite3_column_int  ( selectStatement, 2 );
        double  sightlat = (double)    sqlite3_column_double  ( selectStatement, 3 );
        double  sightlng = (double)    sqlite3_column_double  ( selectStatement, 4 );
        char *  sighttitle = (char*)    sqlite3_column_text  ( selectStatement, 5 );
        char *  contact = (char*)    sqlite3_column_text  ( selectStatement, 6 );
        char *  address = (char*)    sqlite3_column_text  ( selectStatement, 7 );
        char*  weburl = (char*)    sqlite3_column_text  ( selectStatement, 8 );
        char*  typeShop = (char*)    sqlite3_column_text  ( selectStatement, 9 );
        double date = (double) sqlite3_column_double (selectStatement, 10);
        ShopsModel * restaurant = [[ShopsModel alloc] init];
        restaurant.imagesFirst = [NSString stringWithString:[NSString stringWithUTF8String:imagesfirst]];
        restaurant.sightDescription = [NSString stringWithString:[NSString stringWithUTF8String:sightdescription]];
        restaurant.sightID = [NSNumber numberWithInt:sightid];
        restaurant.sightLat = [NSNumber numberWithFloat:sightlat];
        restaurant.sightLng = [NSNumber numberWithFloat:sightlng];
        restaurant.sightTitle = [NSString stringWithString:[NSString stringWithUTF8String:sighttitle]];
        restaurant.webURL = [NSString stringWithString:[NSString stringWithUTF8String:weburl]];
        restaurant.contact = [NSString stringWithString:[NSString stringWithUTF8String:contact]];
        restaurant.address = [NSString stringWithString:[NSString stringWithUTF8String:address]];
        restaurant.typeShop = [NSString stringWithString:[NSString stringWithUTF8String:typeShop]];
        restaurant.date = [NSDate dateWithTimeIntervalSince1970:date];
        [self selectImageByType:@"shops" andObjID:restaurant.sightID withHandle:^(NSArray<NSString *> *images) {
            restaurant.imagesArray = [[NSMutableArray alloc] initWithArray:images];
        }];
        
        [dbOrders addObject:restaurant];
    }
    sqlite3_finalize ( selectStatement );
    
    if ( dbOrders.count )
    {
        handler ( dbOrders );
    }else{
        handler (nil);
    }
}
-(void)deleteAllShops{
    if ( ! dbIsOK )
    {
        return;
    }
    
    sqlite3_stmt * deleteStatement;
    int result = sqlite3_prepare_v2 ( tktDB, [deleteShops UTF8String], -1, & deleteStatement, NULL );
    
    if ( result != SQLITE_OK )
    {
        [self logError:@"sqlite3_prepare_v2 failed for \"deleteCategories\" with return code %d",result];
        return;
    }
    
    result = sqlite3_step (deleteStatement);
    if ( result != SQLITE_DONE )
    {
        [self logError:@"sqlite3_step failed for \"deleteCategories\" with return code %d",result];
    }
    sqlite3_finalize ( deleteStatement );
    [self deleteImages:@"shops"];
}
-(void)deleteShops:(int)shopID{
    if ( ! dbIsOK )
    {
        return;
    }
    
    sqlite3_stmt * deleteStatement;
    int result = sqlite3_prepare_v2 ( tktDB, [[NSString stringWithFormat:deleteShopsWithID,shopID] UTF8String], -1, & deleteStatement, NULL );
    
    if ( result != SQLITE_OK )
    {
        [self logError:@"sqlite3_prepare_v2 failed for \"deleteCategories\" with return code %d",result];
        return;
    }
    
    result = sqlite3_step (deleteStatement);
    if ( result != SQLITE_DONE )
    {
        [self logError:@"sqlite3_step failed for \"deleteCategories\" with return code %d",result];
    }
    sqlite3_finalize ( deleteStatement );
    [self deleteImages:@"shops" withID:shopID];
}
#pragma mark - Festivals

-(void)setFestivals:(NSArray<FestivalsModel*>*)festivals{
    if ( ! dbIsOK )
    {
        return;
    }
    [self deleteAllFestival];
    for ( FestivalsModel * shop in festivals )
    {
        sqlite3_stmt * insertStatement;
        NSString *descriptionStr =  [shop.sightDescription stringByReplacingOccurrencesOfString:@ "'" withString: @"''"];
        NSString * insertCategory = [NSString stringWithFormat:insertFestivals, shop.imagesFirst,
                                     descriptionStr,
                                     (long)[shop.sightID integerValue],
                                     [shop.sightLat doubleValue],
                                     [shop.sightLng doubleValue],
                                     shop.sightTitle,
                                     shop.address,
                                     shop.contact,
                                     shop.typeFestival,
                                     shop.venueName,
                                     [shop.eventDate timeIntervalSince1970]
                                     ];
        int result = sqlite3_prepare_v2 ( tktDB, [insertCategory UTF8String], -1, & insertStatement, NULL );
        if ( result == SQLITE_OK )
        {
            result = sqlite3_step (insertStatement);
            if ( result != SQLITE_DONE )
            {
                [self logError:@"sqlite3_step failed for \"insertCategory\""];
                [self logDBError:result];
            }
        }
        else
        {
            [self logError:@"sqlite3_prepare_v2 failed for \"insertCategory\""];
            [self logDBError:result];
        }
        sqlite3_finalize ( insertStatement );
        for (int i= 0; i<shop.imagesArray.count; i++) {
            [self insertImages:@"festivals" withUrl:shop.imagesArray[i] withID:shop.sightID];
        }
    }
}
-(void)selectFestivals:(void (^)(NSArray<FestivalsModel *> *))handler{
    if ( ! dbIsOK )
    {
        handler(nil);
        return;
    }
    sqlite3_stmt * selectStatement;
    int result = sqlite3_prepare_v2 ( tktDB, [selectFestivals UTF8String], -1, & selectStatement, NULL );
    if ( result != SQLITE_OK )
    {
        [self logError:@"sqlite3_prepare_v2 failed for \"selectCategories\" with return code %d",result];
        handler (nil);
    }
    
    NSMutableArray * dbOrders = [[NSMutableArray alloc] init];
    
    while ( sqlite3_step ( selectStatement ) == SQLITE_ROW )
    {
        char * imagesfirst = (char*)    sqlite3_column_text  ( selectStatement, 0 );
        char * sightdescription       = (char*)    sqlite3_column_text  ( selectStatement, 1 );
        int    sightid = (int)    sqlite3_column_int  ( selectStatement, 2 );
        double  sightlat = (double)    sqlite3_column_double  ( selectStatement, 3 );
        double  sightlng = (double)    sqlite3_column_double  ( selectStatement, 4 );
        char *  sighttitle = (char*)    sqlite3_column_text  ( selectStatement, 5 );
        char *  address = (char*)    sqlite3_column_text  ( selectStatement, 6 );
        char *  contact = (char*)    sqlite3_column_text  ( selectStatement, 7 );
        char*  typefestival = (char*)    sqlite3_column_text  ( selectStatement, 8 );
        char*  venuename = (char*)    sqlite3_column_text  ( selectStatement, 9 );
        double  eventdate = (double)    sqlite3_column_double  ( selectStatement, 10 );
        
        FestivalsModel * restaurant = [[FestivalsModel alloc] init];
        restaurant.imagesFirst = [NSString stringWithString:[NSString stringWithUTF8String:imagesfirst]];
        restaurant.sightDescription = [NSString stringWithString:[NSString stringWithUTF8String:sightdescription]];
        restaurant.sightID = [NSNumber numberWithInt:sightid];
        restaurant.sightLat = [NSNumber numberWithFloat:sightlat];
        restaurant.sightLng = [NSNumber numberWithFloat:sightlng];
        restaurant.sightTitle = [NSString stringWithString:[NSString stringWithUTF8String:sighttitle]];
        restaurant.contact = [NSString stringWithString:[NSString stringWithUTF8String:contact]];
        restaurant.address = [NSString stringWithString:[NSString stringWithUTF8String:address]];
        restaurant.typeFestival = [NSString stringWithString:[NSString stringWithUTF8String:typefestival]];
        restaurant.venueName = [NSString stringWithString:[NSString stringWithUTF8String:venuename]];
        restaurant.eventDate = [NSDate dateWithTimeIntervalSince1970:eventdate];
        [self selectImageByType:@"festivals" andObjID:restaurant.sightID withHandle:^(NSArray<NSString *> *images) {
            restaurant.imagesArray = [[NSMutableArray alloc] initWithArray:images];
        }];
        
        [dbOrders addObject:restaurant];
    }
    sqlite3_finalize ( selectStatement );
    
    if ( dbOrders.count )
    {
        handler ( dbOrders );
    }else{
        handler (nil);
    }
}
-(void)deleteAllFestival{
    if ( ! dbIsOK )
    {
        return;
    }
    
    sqlite3_stmt * deleteStatement;
    int result = sqlite3_prepare_v2 ( tktDB, [deleteFestivals UTF8String], -1, & deleteStatement, NULL );
    
    if ( result != SQLITE_OK )
    {
        [self logError:@"sqlite3_prepare_v2 failed for \"deleteCategories\" with return code %d",result];
        return;
    }
    
    result = sqlite3_step (deleteStatement);
    if ( result != SQLITE_DONE )
    {
        [self logError:@"sqlite3_step failed for \"deleteCategories\" with return code %d",result];
    }
    sqlite3_finalize ( deleteStatement );
    [self deleteImages:@"festivals"];
}
#pragma mark - Tours
-(void)updateTourToNoLive{
    if ( ! dbIsOK )
    {
        return;
    }
    sqlite3_stmt * insertStatement;
    
    NSString * insertCategory = updateTourNoLive;
    int result = sqlite3_prepare_v2 ( tktDB, [insertCategory UTF8String], -1, & insertStatement, NULL );
    if ( result == SQLITE_OK )
    {
        result = sqlite3_step (insertStatement);
        if ( result != SQLITE_DONE )
        {
            [self logError:@"sqlite3_step failed for \"insertCategory\""];
            [self logDBError:result];
        }
    }
    else
    {
        [self logError:@"sqlite3_prepare_v2 failed for \"insertCategory\""];
        [self logDBError:result];
    }
    sqlite3_finalize ( insertStatement );
}
-(void)updateTourTolive:(ToursModel*)tours withLive:(int)liveTour{
    if ( ! dbIsOK )
    {
        return;
    }
    sqlite3_stmt * insertStatement;
    
    NSString * insertCategory = [NSString stringWithFormat:updateTpurLive,
                                 liveTour,
                                 tours.receptStr,
                                 [tours.toursID intValue]
                                 ];
    int result = sqlite3_prepare_v2 ( tktDB, [insertCategory UTF8String], -1, & insertStatement, NULL );
    if ( result == SQLITE_OK )
    {
        result = sqlite3_step (insertStatement);
        if ( result != SQLITE_DONE )
        {
            [self logError:@"sqlite3_step failed for \"insertCategory\""];
            [self logDBError:result];
        }
    }
    else
    {
        [self logError:@"sqlite3_prepare_v2 failed for \"insertCategory\""];
        [self logDBError:result];
    }
    sqlite3_finalize ( insertStatement );
    NSDictionary *tokenuser = [SharedPreferenceManager getUserInfo];
    if (tokenuser && tours.receptStr == nil) {
        [self setTourUsers:[tours.toursID intValue] withUserToken:[tokenuser[@"id"] stringValue]];
    }
}
-(void)updateTourToRestore:(int)tourID withTourRecept:(NSString*)tourRecept{
    if ( ! dbIsOK )
    {
        return;
    }
    sqlite3_stmt * insertStatement;
    
    NSString * insertCategory = [NSString stringWithFormat:updateTourRestore,
                                 1,
                                 tourRecept,
                                 tourID
                                 ];
    int result = sqlite3_prepare_v2 ( tktDB, [insertCategory UTF8String], -1, & insertStatement, NULL );
    if ( result == SQLITE_OK )
    {
        result = sqlite3_step (insertStatement);
        if ( result != SQLITE_DONE )
        {
            [self logError:@"sqlite3_step failed for \"insertCategory\""];
            [self logDBError:result];
        }
    }
    else
    {
        [self logError:@"sqlite3_prepare_v2 failed for \"insertCategory\""];
        [self logDBError:result];
    }
    sqlite3_finalize ( insertStatement );
}
-(void)updateAllTourToDelete{
    if ( ! dbIsOK )
    {
        return;
    }
    sqlite3_stmt * insertStatement;
    
    NSString * insertCategory = [NSString stringWithFormat:updateAllTourToDelete,
                                 1
                                 ];
    int result = sqlite3_prepare_v2 ( tktDB, [insertCategory UTF8String], -1, & insertStatement, NULL );
    if ( result == SQLITE_OK )
    {
        result = sqlite3_step (insertStatement);
        if ( result != SQLITE_DONE )
        {
            [self logError:@"sqlite3_step failed for \"insertCategory\""];
            [self logDBError:result];
        }
    }
    else
    {
        [self logError:@"sqlite3_prepare_v2 failed for \"insertCategory\""];
        [self logDBError:result];
    }
    sqlite3_finalize ( insertStatement );
}
-(void)updateAllLiveTourToDelete{
    if ( ! dbIsOK )
    {
        return;
    }
    sqlite3_stmt * insertStatement;
    
    NSString * insertCategory = [NSString stringWithFormat:updateAllTourDelete,
                                 1,
                                 0,
                                 1
                                 ];
    int result = sqlite3_prepare_v2 ( tktDB, [insertCategory UTF8String], -1, & insertStatement, NULL );
    if ( result == SQLITE_OK )
    {
        result = sqlite3_step (insertStatement);
        if ( result != SQLITE_DONE )
        {
            [self logError:@"sqlite3_step failed for \"insertCategory\""];
            [self logDBError:result];
        }
    }
    else
    {
        [self logError:@"sqlite3_prepare_v2 failed for \"insertCategory\""];
        [self logDBError:result];
    }
    sqlite3_finalize ( insertStatement );
}
-(void)updateTourToDelete:(ToursModel*)tours{
    if ( ! dbIsOK )
    {
        return;
    }
    sqlite3_stmt * insertStatement;
    
    NSString * insertCategory = [NSString stringWithFormat:updateTourDelete,
                                 1,
                                 tours.receptStr,
                                 [tours.toursID intValue]
                                 ];
    int result = sqlite3_prepare_v2 ( tktDB, [insertCategory UTF8String], -1, & insertStatement, NULL );
    if ( result == SQLITE_OK )
    {
        result = sqlite3_step (insertStatement);
        if ( result != SQLITE_DONE )
        {
            [self logError:@"sqlite3_step failed for \"insertCategory\""];
            [self logDBError:result];
        }
    }
    else
    {
        [self logError:@"sqlite3_prepare_v2 failed for \"insertCategory\""];
        [self logDBError:result];
    }
    sqlite3_finalize ( insertStatement );
}
-(void)updateTours:(NSArray<ToursModel *> *)tours{
    if ( ! dbIsOK )
    {
        return;
    }
    for ( ToursModel * shop in tours )
    {
        [self deleteImages:@"tours" withID:[shop.toursID intValue]];
    }
    for ( ToursModel * tour in tours )
    {
        sqlite3_stmt * insertStatement;
        NSString *descriptionStr =  [tour.tourDescription stringByReplacingOccurrencesOfString:@ "'" withString: @"''"];
        
        NSString * insertCategory = [NSString stringWithFormat:updateTour,
                                     tour.polylineStr,
                                     tour.tourTotalPrice,
                                     [tour.cityID intValue],
                                     [tour.distance doubleValue],
                                     [tour.duration doubleValue],
                                     tour.tourTitle,
                                     descriptionStr,
                                     tour.break_tip,
                                     tour.notes,
                                     tour.finish,
                                     tour.start,
                                     [tour.date timeIntervalSince1970],
                                     tour.isPopupar,
                                     tour.tourIsFree,
                                     (long)tour.tourRaiting,
                                     [tour.toursID intValue]
                                     ];
        int result = sqlite3_prepare_v2 ( tktDB, [insertCategory UTF8String], -1, & insertStatement, NULL );
        if ( result == SQLITE_OK )
        {
            result = sqlite3_step (insertStatement);
            if ( result != SQLITE_DONE )
            {
                [self logError:@"sqlite3_step failed for \"insertCategory\""];
                [self logDBError:result];
            }
        }
        else
        {
            [self logError:@"sqlite3_prepare_v2 failed for \"insertCategory\""];
            [self logDBError:result];
        }
        sqlite3_finalize ( insertStatement );
        for (int i= 0; i<tour.toursImages.count; i++) {
            [self insertImages:@"tours" withUrl:tour.toursImages[i] withID:tour.toursID];
        }
        [self deleteTourSight:[tour.toursID intValue] withType:@"tours"];
        for (int i = 0; i<tour.sightTour.count; i++) {
            SightModel *sightModel = tour.sightTour[i];
            [self setToursSight:[tour.toursID intValue] andSightID:[sightModel.sightID intValue] andType:@"tours"];
        }
        [self setFilterHelper:@"tours" sightID:[tour.toursID intValue] filterID:tour.category];
    }
}
-(void)setTours:(NSArray<ToursModel *> *)tours needDelete:(BOOL)delete{
    if ( ! dbIsOK )
    {
        return;
    }
    if (delete) {
        [self deleteAllTours];
    }else{
        for ( ToursModel * shop in tours )
        {
            [self deleteTours:[shop.toursID intValue]];
        }
    }
    for ( ToursModel * tour in tours )
    {
        sqlite3_stmt * insertStatement;
        NSString *descriptionStr =  [tour.tourDescription stringByReplacingOccurrencesOfString:@ "'" withString: @"''"];
        NSString * insertCategory = [NSString stringWithFormat:insertTours,
                                     [tour.toursID intValue],
                                     tour.polylineStr,
                                     tour.tourTotalPrice,
                                     [tour.cityID intValue],
                                     [tour.distance doubleValue],
                                     [tour.duration doubleValue],
                                     tour.tourTitle,
                                     descriptionStr,
                                     tour.break_tip,
                                     tour.notes,
                                     tour.finish,
                                     tour.start,
                                     [tour.date timeIntervalSince1970],
                                     0,
                                     tour.isPopupar,
                                     tour.receptStr,
                                     tour.tourIsFree,
                                     (long)tour.tourRaiting
                                     ];
        int result = sqlite3_prepare_v2 ( tktDB, [insertCategory UTF8String], -1, & insertStatement, NULL );
        if ( result == SQLITE_OK )
        {
            result = sqlite3_step (insertStatement);
            if ( result != SQLITE_DONE )
            {
                [self logError:@"sqlite3_step failed for \"insertCategory\""];
                [self logDBError:result];
            }
        }
        else
        {
            [self logError:@"sqlite3_prepare_v2 failed for \"insertCategory\""];
            [self logDBError:result];
        }
        sqlite3_finalize ( insertStatement );
        for (int i= 0; i<tour.toursImages.count; i++) {
            [self insertImages:@"tours" withUrl:tour.toursImages[i] withID:tour.toursID];
        }
        [self deleteTourSight:[tour.toursID intValue] withType:@"tours"];
        for (int i = 0; i<tour.sightTour.count; i++) {
            SightModel *sightModel = tour.sightTour[i];
            [self setToursSight:[tour.toursID intValue] andSightID:[sightModel.sightID intValue] andType:@"tours"];
        }
        [self setFilterHelper:@"tours" sightID:[tour.toursID intValue] filterID:tour.category];
    }
}

-(void)submitRaiting:(NSInteger)raiting withTourID:(int)tourID{
    if ( ! dbIsOK )
    {
        return;
    }
    sqlite3_stmt * insertStatement;
    
    NSString * insertCategory = [NSString stringWithFormat:submitTourRaview,
                                 (long)raiting,
                                 1,
                                 tourID
                                 ];
    int result = sqlite3_prepare_v2 ( tktDB, [insertCategory UTF8String], -1, & insertStatement, NULL );
    if ( result == SQLITE_OK )
    {
        result = sqlite3_step (insertStatement);
        if ( result != SQLITE_DONE )
        {
            [self logError:@"sqlite3_step failed for \"insertCategory\""];
            [self logDBError:result];
        }
    }
    else
    {
        [self logError:@"sqlite3_prepare_v2 failed for \"insertCategory\""];
        [self logDBError:result];
    }
    sqlite3_finalize ( insertStatement );
}

-(void)selectTours:(void (^)(NSArray<ToursModel *> *))handler{
    if ( ! dbIsOK )
    {
        handler(nil);
        return;
    }
    sqlite3_stmt * selectStatement;
    int result = sqlite3_prepare_v2 ( tktDB, [selectTours UTF8String], -1, & selectStatement, NULL );
    if ( result != SQLITE_OK )
    {
        [self logError:@"sqlite3_prepare_v2 failed for \"selectCategories\" with return code %d",result];
        handler (nil);
    }
    
    NSMutableArray * dbOrders = [[NSMutableArray alloc] init];
    
    while ( sqlite3_step ( selectStatement ) == SQLITE_ROW )
    {
        int  toursid = (int)    sqlite3_column_int  ( selectStatement, 0 );
        char * polylinestr       = (char*)    sqlite3_column_text  ( selectStatement, 1 );
        char *    tourtotalprice = (char*)    sqlite3_column_text  ( selectStatement, 2 );
        int  cityid = (int)    sqlite3_column_int  ( selectStatement, 3 );
        double  distance = (double)    sqlite3_column_double  ( selectStatement, 4 );
        double  duration = (double)  sqlite3_column_double  ( selectStatement, 5 );
        char *  tourtitle = (char*)    sqlite3_column_text  ( selectStatement, 6 );
        char *  tourdescription = (char*)    sqlite3_column_text  ( selectStatement, 7 );
        char*  breaktip = (char*)    sqlite3_column_text  ( selectStatement, 8 );
        char*  notes = (char*)    sqlite3_column_text  ( selectStatement, 9 );
        char*  finish = (char*)    sqlite3_column_text  ( selectStatement, 10 );
        char*  start = (char*)    sqlite3_column_text  ( selectStatement, 11 );
        double date = (double) sqlite3_column_double (selectStatement, 12);
        int livedemo = (int) sqlite3_column_int(selectStatement,13);
        int  popilar = (int)    sqlite3_column_int  ( selectStatement, 14 );
        char*  receptStr = (char*)    sqlite3_column_text  ( selectStatement, 15 );
        int  tourfree = (int)    sqlite3_column_int  ( selectStatement, 16 );
        int  raitingTour = (int)    sqlite3_column_int  ( selectStatement, 17 );
        int  isDeleteTour = (int)    sqlite3_column_int  ( selectStatement, 18 );
        int  toirIsrait = (int)    sqlite3_column_int  ( selectStatement, 19 );

        ToursModel * tour = [[ToursModel alloc] init];
        tour.toursID = [NSNumber numberWithInt:toursid];
        tour.polylineStr = [NSString stringWithString:[NSString stringWithUTF8String:polylinestr]];
        NSString *priceStr = [NSString stringWithString:[NSString stringWithUTF8String:tourtotalprice]];
        tour.tourTotalPrice = [NSNumber numberWithFloat:[priceStr floatValue]];
        tour.cityID = [NSNumber numberWithInt:cityid];
        tour.distance = [NSNumber numberWithFloat:distance];
        tour.duration = [NSNumber numberWithFloat:duration];
        tour.tourTitle = [NSString stringWithString:[NSString stringWithUTF8String:tourtitle]];
        tour.tourDescription = [NSString stringWithString:[NSString stringWithUTF8String:tourdescription]];
        tour.break_tip = [NSString stringWithString:[NSString stringWithUTF8String:breaktip]];
        tour.notes = [NSString stringWithString:[NSString stringWithUTF8String:notes]];
        tour.finish = [NSString stringWithString:[NSString stringWithUTF8String:finish]];
        tour.start = [NSString stringWithString:[NSString stringWithUTF8String:start]];
        tour.polyline = [self convertStringToArray:tour.polylineStr];
        tour.date = [NSDate dateWithTimeIntervalSince1970:date];
        tour.tourlive = livedemo;
        tour.isPopupar = popilar;
        tour.receptStr = [NSString stringWithString:[NSString stringWithUTF8String:receptStr]];
        tour.tourIsFree = tourfree;
        tour.tourRaiting = raitingTour;
        tour.isDeleteTour = isDeleteTour;
        tour.tourIsRait = toirIsrait;
        [self selectImageByType:@"tours" andObjID:tour.toursID withHandle:^(NSArray<NSString *> *images) {
            tour.toursImages = [[NSMutableArray alloc] initWithArray:images];
        }];
        [self selectToursUser:[tour.toursID intValue] withHandle:^(NSArray<NSString *> *tokens) {
            tour.userTokens = tokens;
        }];
        [self selectToursSight:[tour.toursID intValue] withType:@"tours" withHandle:^(NSArray<NSNumber *> *sightIDs) {
            if (sightIDs) {
                if (sightIDs.count > 0) {
                    tour.sightTour = [[NSMutableArray alloc] initWithCapacity:sightIDs.count];
                    for (int i = 0; i<sightIDs.count; i++) {
                        [self selectSights:[sightIDs[i] intValue] withHandle:^(SightModel *sightss) {
                            [tour.sightTour addObject:sightss];
                        }];
                    }
                }
            }
        }];
        [self selectFilterHelper:[tour.toursID intValue] wihtType:@"tours" andHandle:^(NSArray<NSNumber *> *filterID) {
            tour.category = [[NSMutableArray alloc] initWithCapacity:filterID.count];
            for (int i= 0; i<filterID.count; i++) {
                FilterModel *model = [[FilterModel alloc] init];
                model.filterID = filterID[i];
                model.title = @"";
                [tour.category addObject:model];
            }
        }];
        [dbOrders addObject:tour];
    }
    sqlite3_finalize ( selectStatement );
    
    if ( dbOrders.count )
    {
        handler ( dbOrders );
    }else{
        handler (nil);
    }
}

-(void)selectTours:(int)tourID withHandle:(void (^)(ToursModel *))handler{
    if ( ! dbIsOK )
    {
        handler(nil);
        return;
    }
    sqlite3_stmt * selectStatement;
    int result = sqlite3_prepare_v2 ( tktDB, [[NSString stringWithFormat:selectToursWithID,tourID] UTF8String], -1, & selectStatement, NULL );
    if ( result != SQLITE_OK )
    {
        [self logError:@"sqlite3_prepare_v2 failed for \"selectCategories\" with return code %d",result];
        handler (nil);
    }
    
    ToursModel * tour;
    
    while ( sqlite3_step ( selectStatement ) == SQLITE_ROW )
    {
        int  toursid = (int)    sqlite3_column_int  ( selectStatement, 0 );
        char * polylinestr       = (char*)    sqlite3_column_text  ( selectStatement, 1 );
        char *    tourtotalprice = (char*)    sqlite3_column_text  ( selectStatement, 2 );
        int  cityid = (int)    sqlite3_column_int  ( selectStatement, 3 );
        double  distance = (double)    sqlite3_column_double  ( selectStatement, 4 );
        double  duration = (double)  sqlite3_column_double  ( selectStatement, 5 );
        char *  tourtitle = (char*)    sqlite3_column_text  ( selectStatement, 6 );
        char *  tourdescription = (char*)    sqlite3_column_text  ( selectStatement, 7 );
        char*  breaktip = (char*)    sqlite3_column_text  ( selectStatement, 8 );
        char*  notes = (char*)    sqlite3_column_text  ( selectStatement, 9 );
        char*  finish = (char*)    sqlite3_column_text  ( selectStatement, 10 );
        char*  start = (char*)    sqlite3_column_text  ( selectStatement, 11 );
        int  popilar = (int)    sqlite3_column_int  ( selectStatement, 14 );
        char*  receptStr = (char*)    sqlite3_column_text  ( selectStatement, 15 );
        int  tourfree = (int)    sqlite3_column_int  ( selectStatement, 16 );
        int  raiting = (int)    sqlite3_column_int  ( selectStatement, 17 );
        int  isDeleteTour = (int)    sqlite3_column_int  ( selectStatement, 18 );
        int  toirIsrait = (int)    sqlite3_column_int  ( selectStatement, 19 );

        tour = [[ToursModel alloc] init];
        tour.toursID = [NSNumber numberWithInt:toursid];
        tour.polylineStr = [NSString stringWithString:[NSString stringWithUTF8String:polylinestr]];
        NSString *priceStr = [NSString stringWithString:[NSString stringWithUTF8String:tourtotalprice]];
        tour.tourTotalPrice = [NSNumber numberWithFloat:[priceStr floatValue]];
        tour.cityID = [NSNumber numberWithInt:cityid];
        tour.distance = [NSNumber numberWithFloat:distance];
        tour.duration = [NSNumber numberWithFloat:duration];
        tour.tourTitle = [NSString stringWithString:[NSString stringWithUTF8String:tourtitle]];
        tour.tourDescription = [NSString stringWithString:[NSString stringWithUTF8String:tourdescription]];
        tour.break_tip = [NSString stringWithString:[NSString stringWithUTF8String:breaktip]];
        tour.notes = [NSString stringWithString:[NSString stringWithUTF8String:notes]];
        tour.finish = [NSString stringWithString:[NSString stringWithUTF8String:finish]];
        tour.start = [NSString stringWithString:[NSString stringWithUTF8String:start]];
        tour.polyline = [self convertStringToArray:tour.polylineStr];
        tour.isPopupar = popilar;
        tour.receptStr = [NSString stringWithString:[NSString stringWithUTF8String:receptStr]];
        tour.tourIsFree = tourfree;
        tour.tourRaiting = raiting;
        tour.isDeleteTour = isDeleteTour;
        tour.tourIsRait = toirIsrait;
        
        [self selectImageByType:@"tours" andObjID:tour.toursID withHandle:^(NSArray<NSString *> *images) {
            tour.toursImages = [[NSMutableArray alloc] initWithArray:images];
        }];
        [self selectToursUser:[tour.toursID intValue] withHandle:^(NSArray<NSString *> *tokens) {
            tour.userTokens = tokens;
        }];
        [self selectToursSight:[tour.toursID intValue] withType:@"tours" withHandle:^(NSArray<NSNumber *> *sightIDs) {
            if (sightIDs) {
                if (sightIDs.count > 0) {
                    tour.sightTour = [[NSMutableArray alloc] initWithCapacity:sightIDs.count];
                    for (int i = 0; i<sightIDs.count; i++) {
                        [self selectSights:[sightIDs[i] intValue] withHandle:^(SightModel *sightss) {
                            [tour.sightTour addObject:sightss];
                        }];
                    }
                }
            }
        }];
        [self selectFilterHelper:[tour.toursID intValue] wihtType:@"tours" andHandle:^(NSArray<NSNumber *> *filterID) {
            tour.category = [[NSMutableArray alloc] initWithCapacity:filterID.count];
            for (int i= 0; i<filterID.count; i++) {
                FilterModel *model = [[FilterModel alloc] init];
                model.filterID = filterID[i];
                model.title = @"";
                [tour.category addObject:model];
            }
        }];
    }
    sqlite3_finalize ( selectStatement );
    
    if ( tour )
    {
        handler ( tour );
    }
}

-(NSMutableArray<CLLocation*> *)convertStringToArray:(NSString*)arrayStr{
    NSArray *jsonObject = [NSJSONSerialization JSONObjectWithData:[arrayStr dataUsingEncoding:NSUTF8StringEncoding] options:0 error:NULL];
    NSMutableArray<CLLocation*> *polyline = [[NSMutableArray alloc] initWithCapacity:jsonObject.count];
    for (int i = 0; i<jsonObject.count; i++) {
        NSArray *item = jsonObject[i];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:[item[0] doubleValue] longitude:[item[1] doubleValue]];
        [polyline addObject:location];
    }
    return polyline;
}
-(void)deleteTours:(int)tourID{
    if ( ! dbIsOK )
    {
        return;
    }
    
    sqlite3_stmt * deleteStatement;
    int result = sqlite3_prepare_v2 ( tktDB, [[NSString stringWithFormat:deleteToursWithID,tourID] UTF8String], -1, & deleteStatement, NULL );
    
    if ( result != SQLITE_OK )
    {
        [self logError:@"sqlite3_prepare_v2 failed for \"deleteCategories\" with return code %d",result];
        return;
    }
    
    result = sqlite3_step (deleteStatement);
    if ( result != SQLITE_DONE )
    {
        [self logError:@"sqlite3_step failed for \"deleteCategories\" with return code %d",result];
    }
    sqlite3_finalize ( deleteStatement );
    [self deleteImages:@"tours" withID:tourID];
}
-(void)deleteAllTours{
    if ( ! dbIsOK )
    {
        return;
    }
    
    sqlite3_stmt * deleteStatement;
    int result = sqlite3_prepare_v2 ( tktDB, [deleteTours UTF8String], -1, & deleteStatement, NULL );
    
    if ( result != SQLITE_OK )
    {
        [self logError:@"sqlite3_prepare_v2 failed for \"deleteCategories\" with return code %d",result];
        return;
    }
    
    result = sqlite3_step (deleteStatement);
    if ( result != SQLITE_DONE )
    {
        [self logError:@"sqlite3_step failed for \"deleteCategories\" with return code %d",result];
    }
    sqlite3_finalize ( deleteStatement );
    [self deleteImages:@"tours"];
}

#pragma mark - Sights

-(void)updateSigtToPass:(int)sightID{
    if ( ! dbIsOK )
    {
        return;
    }
    sqlite3_stmt * insertStatement;
    
    NSString * insertCategory = [NSString stringWithFormat:updateSightToPass,
                                 1,
                                 sightID
                                 ];
    int result = sqlite3_prepare_v2 ( tktDB, [insertCategory UTF8String], -1, & insertStatement, NULL );
    if ( result == SQLITE_OK )
    {
        result = sqlite3_step (insertStatement);
        if ( result != SQLITE_DONE )
        {
            [self logError:@"sqlite3_step failed for \"insertCategory\""];
            [self logDBError:result];
        }
    }
    else
    {
        [self logError:@"sqlite3_prepare_v2 failed for \"insertCategory\""];
        [self logDBError:result];
    }
    sqlite3_finalize ( insertStatement );
}
-(void)updateSigt:(int)sightID{
    if ( ! dbIsOK )
    {
        return;
    }
    sqlite3_stmt * insertStatement;
    
    NSString * insertCategory = [NSString stringWithFormat:updateSight,
                                 1,
                                 sightID
                                 ];
    int result = sqlite3_prepare_v2 ( tktDB, [insertCategory UTF8String], -1, & insertStatement, NULL );
    if ( result == SQLITE_OK )
    {
        result = sqlite3_step (insertStatement);
        if ( result != SQLITE_DONE )
        {
            [self logError:@"sqlite3_step failed for \"insertCategory\""];
            [self logDBError:result];
        }
    }
    else
    {
        [self logError:@"sqlite3_prepare_v2 failed for \"insertCategory\""];
        [self logDBError:result];
    }
    sqlite3_finalize ( insertStatement );
}
-(void)updateHoleSigt:(NSArray<SightModel *> *)tours{
    if ( ! dbIsOK )
    {
        return;
    }
    for ( SightModel * shop in tours )
    {
        [self deleteImages:@"sights" withID:[shop.sightID intValue]];
    }
    
    for ( SightModel * shop in tours )
    {
        sqlite3_stmt * insertStatement;
        NSArray *audioArray = shop.audiosFirst;
        NSArray *audioArrayName = shop.audiosFirstName;
        NSString *audioStr = @"";
        NSString *audioName = @"";
        if (audioArray.count > 0) {
            audioStr = audioArray[0];
        }
        if (audioArrayName.count > 0) {
            audioName = audioArrayName[0];
        }
        NSString *descriptionStr =  [shop.sightDescription stringByReplacingOccurrencesOfString:@ "'" withString: @"''"];
        NSString * insertCategory = [NSString stringWithFormat:updateHoleSight, shop.imagesFirst,
                                     descriptionStr,
                                     [shop.sightID intValue],
                                     [shop.sightLat doubleValue],
                                     [shop.sightLng doubleValue],
                                     shop.sightTitle,
                                     [shop.date timeIntervalSince1970],
                                     audioStr,
                                     audioName,
                                     shop.must_see,
                                     [shop.cityID intValue],
                                     (unsigned long)shop.sightPrice,
                                     shop.needUpdate,
                                     (unsigned long)[shop.auidoFileMemory unsignedIntegerValue],
                                     [shop.sightID intValue]
                                     ];
        int result = sqlite3_prepare_v2 ( tktDB, [insertCategory UTF8String], -1, & insertStatement, NULL );
        if ( result == SQLITE_OK )
        {
            result = sqlite3_step (insertStatement);
            if ( result != SQLITE_DONE )
            {
                [self logError:@"sqlite3_step failed for \"insertCategory\""];
                [self logDBError:result];
            }
        }
        else
        {
            [self logError:@"sqlite3_prepare_v2 failed for \"insertCategory\""];
            [self logDBError:result];
        }
        sqlite3_finalize ( insertStatement );
        for (int i= 0; i<shop.imagesArray.count; i++) {
            [self insertImages:@"sights" withUrl:shop.imagesArray[i] withID:shop.sightID];
        }
        [self deleteSightTour:[shop.sightID intValue] withType:@"sights"];
        for (int i = 0; i<shop.tours.count; i++) {
            ToursModel *sightModel = shop.tours[i];
            [self setToursSight:[sightModel.toursID intValue] andSightID:[shop.sightID intValue] andType:@"sights"];
        }
        [self setFilterHelper:@"sights" sightID:[shop.sightID intValue] filterID:shop.category];
    }
    
}
-(void)updateSightAudio:(int)sightID withAudio:(NSString *)audioStr withRecept:(NSString*)recept{
    
    if ( ! dbIsOK )
    {
        return;
    }
    sqlite3_stmt * insertStatement;
    NSString * insertCategory = [NSString stringWithFormat:updateSightLocalAudi, audioStr, 0,recept,
                                 sightID
                                 ];
    int result = sqlite3_prepare_v2 ( tktDB, [insertCategory UTF8String], -1, & insertStatement, NULL );
    if ( result == SQLITE_OK )
    {
        result = sqlite3_step (insertStatement);
        if ( result != SQLITE_DONE )
        {
            [self logError:@"sqlite3_step failed for \"insertCategory\""];
            [self logDBError:result];
        }
    }
    else
    {
        [self logError:@"sqlite3_prepare_v2 failed for \"insertCategory\""];
        [self logDBError:result];
    }
    sqlite3_finalize ( insertStatement );
}
-(void)setSights:(NSArray<SightModel *> *)tours needDelete:(BOOL)delete{
    if ( ! dbIsOK )
    {
        return;
    }
    if(delete){
        [self deleteAllSights];
    }else{
        for ( SightModel * shop in tours )
        {
            [self deleteSights:[shop.sightID intValue]];
        }
    }
    
    for ( SightModel * shop in tours )
    {
        sqlite3_stmt * insertStatement;
        NSArray *audioArray = shop.audiosFirst;
        NSArray *audioArrayName = shop.audiosFirstName;
        NSString *audioStr = @"";
        NSString *audioName = @"";
        if (audioArray.count > 0 && audioArrayName.count > 0) {
            audioStr = audioArray[0];
            audioName = audioArrayName[0];
        }
        NSString *descriptionStr =  [shop.sightDescription stringByReplacingOccurrencesOfString:@ "'" withString: @"''"];
        NSString * insertCategory = [NSString stringWithFormat:insertSights, shop.imagesFirst,
                                     descriptionStr,
                                     [shop.sightID intValue],
                                     [shop.sightLat doubleValue],
                                     [shop.sightLng doubleValue],
                                     shop.sightTitle,
                                     (unsigned long)shop.sightPrice,
                                     [shop.date timeIntervalSince1970],
                                     audioStr,
                                     audioName,
                                     @"",
                                     shop.must_see,
                                     [shop.cityID intValue],
                                     shop.needUpdate,
                                     (unsigned long)[shop.auidoFileMemory unsignedIntegerValue],
                                     shop.sightIsPass,
                                     shop.baseReceptStr
                                     ];
        int result = sqlite3_prepare_v2 ( tktDB, [insertCategory UTF8String], -1, & insertStatement, NULL );
        if ( result == SQLITE_OK )
        {
            result = sqlite3_step (insertStatement);
            if ( result != SQLITE_DONE )
            {
                [self logError:@"sqlite3_step failed for \"insertCategory\""];
                [self logDBError:result];
            }
        }
        else
        {
            [self logError:@"sqlite3_prepare_v2 failed for \"insertCategory\""];
            [self logDBError:result];
        }
        sqlite3_finalize ( insertStatement );
        for (int i= 0; i<shop.imagesArray.count; i++) {
            [self insertImages:@"sights" withUrl:shop.imagesArray[i] withID:shop.sightID];
        }
        [self deleteSightTour:[shop.sightID intValue] withType:@"sights"];
        for (int i = 0; i<shop.tours.count; i++) {
            ToursModel *sightModel = shop.tours[i];
            [self setToursSight:[sightModel.toursID intValue] andSightID:[shop.sightID intValue] andType:@"sights"];
        }
        [self setFilterHelper:@"sights" sightID:[shop.sightID intValue] filterID:shop.category];
    }
}
-(void)selectSights:(int)sightID withHandle:(void (^)(SightModel*))handler{
    if ( ! dbIsOK )
    {
        handler(nil);
        return;
    }
    sqlite3_stmt * selectStatement;
    int result = sqlite3_prepare_v2 ( tktDB, [[NSString stringWithFormat:selectSightsWithID,sightID] UTF8String], -1, & selectStatement, NULL );
    if ( result != SQLITE_OK )
    {
        [self logError:@"sqlite3_prepare_v2 failed for \"selectCategories\" with return code %d",result];
        handler (nil);
    }
    
    SightModel * restaurant;

    while ( sqlite3_step ( selectStatement ) == SQLITE_ROW )
    {
        restaurant = [[SightModel alloc] init];
        char * imagesfirst = (char*)    sqlite3_column_text  ( selectStatement, 0 );
        char * sightdescription       = (char*)    sqlite3_column_text  ( selectStatement, 1 );
        int    sightid = (int)    sqlite3_column_int  ( selectStatement, 2 );
        double  sightlat = (double)    sqlite3_column_double  ( selectStatement, 3 );
        double  sightlng = (double)    sqlite3_column_double  ( selectStatement, 4 );
        char *  sighttitle = (char*)    sqlite3_column_text  ( selectStatement, 5 );
        int priceSigh = (int) sqlite3_column_int(selectStatement,6);
        double  date = (double)    sqlite3_column_double  ( selectStatement, 7 );
        char *  audio_en = (char*)    sqlite3_column_text  ( selectStatement, 8 );
        char *  audioName_en = (char*)    sqlite3_column_text  ( selectStatement, 9 );
        char *  audioName_local = (char*)    sqlite3_column_text  ( selectStatement, 10 );
        int    mustsee = (int)    sqlite3_column_int  ( selectStatement, 11 );
        int    cityid = (int)    sqlite3_column_int  ( selectStatement, 12 );
        int    needUpdate = (int)    sqlite3_column_int  ( selectStatement, 13 );
        long long int    audioMemory = (long long int)    sqlite3_column_int64  ( selectStatement, 14 );
        int    sightIsPass = (int)    sqlite3_column_int  ( selectStatement, 15 );
        char *  baseReceptStr = (char*)    sqlite3_column_text  ( selectStatement, 16 );


        restaurant.imagesFirst = [NSString stringWithString:[NSString stringWithUTF8String:imagesfirst]];
        restaurant.sightDescription = [NSString stringWithString:[NSString stringWithUTF8String:sightdescription]];
        restaurant.sightID = [NSNumber numberWithInt:sightid];
        restaurant.sightLat = [NSNumber numberWithFloat:sightlat];
        restaurant.sightLng = [NSNumber numberWithFloat:sightlng];
        restaurant.sightTitle = [NSString stringWithString:[NSString stringWithUTF8String:sighttitle]];
        restaurant.sightPrice = priceSigh;
        restaurant.date = [NSDate dateWithTimeIntervalSince1970:date];
        restaurant.audiosFirst = [[NSMutableArray alloc] initWithArray:@[[NSString stringWithString:[NSString stringWithUTF8String:audio_en]]]];
        restaurant.audiosFirstName = [[NSMutableArray alloc] initWithArray:@[[NSString stringWithString:[NSString stringWithUTF8String:audioName_en]]]];
        restaurant.audioName_Local = [NSString stringWithString:[NSString stringWithUTF8String:audioName_local]];;
        restaurant.must_see = mustsee;
        restaurant.cityID = [NSNumber numberWithInt:cityid];
        restaurant.needUpdate = needUpdate;
        restaurant.auidoFileMemory = [NSNumber numberWithUnsignedInteger:audioMemory];
        restaurant.sightIsPass = sightIsPass;
        restaurant.baseReceptStr = [NSString stringWithString:[NSString stringWithUTF8String:baseReceptStr]];
        
        [self selectImageByType:@"sights" andObjID:restaurant.sightID withHandle:^(NSArray<NSString *> *images) {
            restaurant.imagesArray = [[NSMutableArray alloc] initWithArray:images];
        }];
        [self selectFilterHelper:[restaurant.sightID intValue] wihtType:@"sights" andHandle:^(NSArray<NSNumber *> *filterID) {
            restaurant.category = [[NSMutableArray alloc] initWithCapacity:filterID.count];
            for (int i= 0; i<filterID.count; i++) {
                FilterModel *model = [[FilterModel alloc] init];
                model.filterID = filterID[i];
                model.title = @"";
                [restaurant.category addObject:model];
            }
        }];
    }
    sqlite3_finalize ( selectStatement );
    
    if ( restaurant )
    {
        handler ( restaurant );
    }

}
-(void)selectSights:(void (^)(NSArray<SightModel *> *))handler{
    if ( ! dbIsOK )
    {
        handler(nil);
        return;
    }
    sqlite3_stmt * selectStatement;
    int result = sqlite3_prepare_v2 ( tktDB, [selectSights UTF8String], -1, & selectStatement, NULL );
    if ( result != SQLITE_OK )
    {
        [self logError:@"sqlite3_prepare_v2 failed for \"selectCategories\" with return code %d",result];
        handler (nil);
    }
    
    NSMutableArray * dbOrders = [[NSMutableArray alloc] init];
    
    while ( sqlite3_step ( selectStatement ) == SQLITE_ROW )
    {
        char * imagesfirst = (char*)    sqlite3_column_text  ( selectStatement, 0 );
        char * sightdescription       = (char*)    sqlite3_column_text  ( selectStatement, 1 );
        int    sightid = (int)    sqlite3_column_int  ( selectStatement, 2 );
        double  sightlat = (double)    sqlite3_column_double  ( selectStatement, 3 );
        double  sightlng = (double)    sqlite3_column_double  ( selectStatement, 4 );
        char *  sighttitle = (char*)    sqlite3_column_text  ( selectStatement, 5 );
        int priceSigh = (int) sqlite3_column_int(selectStatement,6);
        double  date = (double)    sqlite3_column_double  ( selectStatement, 7 );
        char *  audio_en = (char*)    sqlite3_column_text  ( selectStatement, 8 );
        char *  audioName_en = (char*)    sqlite3_column_text  ( selectStatement, 9 );
        char *  audioName_local = (char*)    sqlite3_column_text  ( selectStatement, 10 );
        int    mustsee = (int)    sqlite3_column_int  ( selectStatement, 11 );
        int    cityid = (int)    sqlite3_column_int  ( selectStatement, 12 );
        int    needupdate = (int)    sqlite3_column_int  ( selectStatement, 13 );
        long long int    audioMemory = (long long int)    sqlite3_column_int64  ( selectStatement, 14 );
        int    sightIsPass = (int)    sqlite3_column_int  ( selectStatement, 15 );
        char *  baseReceptStr = (char*)    sqlite3_column_text  ( selectStatement, 16 );

        SightModel * restaurant = [[SightModel alloc] init];
        restaurant.imagesFirst = [NSString stringWithString:[NSString stringWithUTF8String:imagesfirst]];
        restaurant.sightDescription = [NSString stringWithString:[NSString stringWithUTF8String:sightdescription]];
        restaurant.sightID = [NSNumber numberWithInt:sightid];
        restaurant.sightLat = [NSNumber numberWithFloat:sightlat];
        restaurant.sightLng = [NSNumber numberWithFloat:sightlng];
        restaurant.sightTitle = [NSString stringWithString:[NSString stringWithUTF8String:sighttitle]];
        restaurant.sightPrice = priceSigh;
        restaurant.date = [NSDate dateWithTimeIntervalSince1970:date];
        restaurant.audiosFirst = [[NSMutableArray alloc] initWithArray:@[[NSString stringWithString:[NSString stringWithUTF8String:audio_en]]]];
        restaurant.audiosFirstName = [[NSMutableArray alloc] initWithArray:@[[NSString stringWithString:[NSString stringWithUTF8String:audioName_en]]]];
        restaurant.audioName_Local = [NSString stringWithString:[NSString stringWithUTF8String:audioName_local]];;
        restaurant.must_see = mustsee;
        restaurant.cityID = [NSNumber numberWithInt:cityid];
        restaurant.needUpdate = needupdate;
        restaurant.auidoFileMemory = [NSNumber numberWithUnsignedInteger:audioMemory];
        restaurant.sightIsPass = sightIsPass;
        restaurant.baseReceptStr = [NSString stringWithString:[NSString stringWithUTF8String:baseReceptStr]];

        [self selectImageByType:@"sights" andObjID:restaurant.sightID withHandle:^(NSArray<NSString *> *images) {
            restaurant.imagesArray = [[NSMutableArray alloc] initWithArray:images];
        }];
        [self selectSightTours:[restaurant.sightID intValue] withType:@"sights" withHandle:^(NSArray<NSNumber *> *toursID) {
            if (toursID) {
                if (toursID.count > 0) {
                    restaurant.tours = [[NSMutableArray alloc] initWithCapacity:toursID.count];
                    for (int i = 0; i<toursID.count; i++) {
                        [self selectTours:[toursID[i] intValue] withHandle:^(ToursModel *tourModel) {
                            [restaurant.tours addObject:tourModel];
                        }];
                    }
                }
            }
        }];
        [self selectFilterHelper:[restaurant.sightID intValue] wihtType:@"sights" andHandle:^(NSArray<NSNumber *> *filterID) {
            restaurant.category = [[NSMutableArray alloc] initWithCapacity:filterID.count];
            for (int i= 0; i<filterID.count; i++) {
                FilterModel *model = [[FilterModel alloc] init];
                model.filterID = filterID[i];
                model.title = @"";
                [restaurant.category addObject:model];
            }
        }];
        [dbOrders addObject:restaurant];
    }
    sqlite3_finalize ( selectStatement );
    
    if ( dbOrders.count )
    {
        handler ( dbOrders );
    }else{
        handler (nil);
    }
}

-(void)deleteAllSights{
    if ( ! dbIsOK )
    {
        return;
    }
    
    sqlite3_stmt * deleteStatement;
    int result = sqlite3_prepare_v2 ( tktDB, [deleteSights UTF8String], -1, & deleteStatement, NULL );
    
    if ( result != SQLITE_OK )
    {
        [self logError:@"sqlite3_prepare_v2 failed for \"deleteCategories\" with return code %d",result];
        return;
    }
    
    result = sqlite3_step (deleteStatement);
    if ( result != SQLITE_DONE )
    {
        [self logError:@"sqlite3_step failed for \"deleteCategories\" with return code %d",result];
    }
    sqlite3_finalize ( deleteStatement );
    [self deleteImages:@"sights"];
}
-(void)deleteSights:(int)sightID{
    if ( ! dbIsOK )
    {
        return;
    }
    
    sqlite3_stmt * deleteStatement;
    int result = sqlite3_prepare_v2 ( tktDB, [[NSString stringWithFormat:deleteSightsWithID,sightID] UTF8String], -1, & deleteStatement, NULL );
    
    if ( result != SQLITE_OK )
    {
        [self logError:@"sqlite3_prepare_v2 failed for \"deleteCategories\" with return code %d",result];
        return;
    }
    
    result = sqlite3_step (deleteStatement);
    if ( result != SQLITE_DONE )
    {
        [self logError:@"sqlite3_step failed for \"deleteCategories\" with return code %d",result];
    }
    sqlite3_finalize ( deleteStatement );
    [self deleteImages:@"sights" withID:sightID];
}
#pragma mark - ToursUsers

-(void)selectToursUser:(int)tourID withHandle:(void (^)(NSArray<NSString *> *))handler{
    if ( ! dbIsOK )
    {
        handler(nil);
        return;
    }
    sqlite3_stmt * selectStatement;
    int result = sqlite3_prepare_v2 ( tktDB, [[NSString stringWithFormat:selectTourUsers,tourID] UTF8String], -1, & selectStatement, NULL );
    if ( result != SQLITE_OK )
    {
        [self logError:@"sqlite3_prepare_v2 failed for \"selectCategories\" with return code %d",result];
        handler (nil);
    }
    
    NSMutableArray * dbOrders = [[NSMutableArray alloc] init];
    
    while ( sqlite3_step ( selectStatement ) == SQLITE_ROW )
    {
        char * userToken       = (char*)    sqlite3_column_text  ( selectStatement, 1 );
        NSString *token = [NSString stringWithString:[NSString stringWithUTF8String:userToken]];
        [dbOrders addObject:token];
    }
    sqlite3_finalize ( selectStatement );
    
    if ( dbOrders.count )
    {
        handler ( dbOrders );
    }else{
        handler (nil);
    }

    
}
-(void)setTourUsers:(int)tourId withUserToken:(NSString*)userTOken{
    if ( ! dbIsOK )
    {
        return;
    }
    sqlite3_stmt * insertStatement;
    
    NSString * insertCategory = [NSString stringWithFormat:insertTourUsers, tourId,
                                 userTOken
                                 ];
    int result = sqlite3_prepare_v2 ( tktDB, [insertCategory UTF8String], -1, & insertStatement, NULL );
    if ( result == SQLITE_OK )
    {
        result = sqlite3_step (insertStatement);
        if ( result != SQLITE_DONE )
        {
            [self logError:@"sqlite3_step failed for \"insertCategory\""];
            [self logDBError:result];
        }
    }
    else
    {
        [self logError:@"sqlite3_prepare_v2 failed for \"insertCategory\""];
        [self logDBError:result];
    }
    sqlite3_finalize ( insertStatement );
}

#pragma mark - ToursSights

-(void)setToursSight:(int)tourID andSightID:(int)sightID andType:(NSString*)type{
    if ( ! dbIsOK )
    {
        return;
    }
        sqlite3_stmt * insertStatement;
        
        NSString * insertCategory = [NSString stringWithFormat:insertToursSights, tourID,
                                     sightID,
                                     type
                                    ];
        int result = sqlite3_prepare_v2 ( tktDB, [insertCategory UTF8String], -1, & insertStatement, NULL );
        if ( result == SQLITE_OK )
        {
            result = sqlite3_step (insertStatement);
            if ( result != SQLITE_DONE )
            {
                [self logError:@"sqlite3_step failed for \"insertCategory\""];
                [self logDBError:result];
            }
        }
        else
        {
            [self logError:@"sqlite3_prepare_v2 failed for \"insertCategory\""];
            [self logDBError:result];
        }
        sqlite3_finalize ( insertStatement );
}
-(void)selectToursSight:(int)toursID withType:(NSString*)type withHandle:(void (^)(NSArray<NSNumber *> *))handler{
    if ( ! dbIsOK )
    {
        handler(nil);
        return;
    }
    sqlite3_stmt * selectStatement;
    int result = sqlite3_prepare_v2 ( tktDB, [[NSString stringWithFormat:selectToursSights,toursID,type] UTF8String], -1, & selectStatement, NULL );
    if ( result != SQLITE_OK )
    {
        [self logError:@"sqlite3_prepare_v2 failed for \"selectCategories\" with return code %d",result];
        handler (nil);
    }
    
    NSMutableArray * dbOrders = [[NSMutableArray alloc] init];
    
    while ( sqlite3_step ( selectStatement ) == SQLITE_ROW )
    {
        int sightID = (int)    sqlite3_column_int  ( selectStatement, 1 );
        
        NSNumber *idSight = [NSNumber numberWithInt:sightID];
        
        [dbOrders addObject:idSight];
    }
    sqlite3_finalize ( selectStatement );
    
    if ( dbOrders.count )
    {
        handler ( dbOrders );
    }else{
        handler (nil);
    }
}
-(void)selectSightTours:(int)sightID withType:(NSString*)type withHandle:(void (^)(NSArray<NSNumber *> *))handler{
    if ( ! dbIsOK )
    {
        handler(nil);
        return;
    }
    sqlite3_stmt * selectStatement;
    int result = sqlite3_prepare_v2 ( tktDB, [[NSString stringWithFormat:selectSightsTours,sightID,type] UTF8String], -1, & selectStatement, NULL );
    if ( result != SQLITE_OK )
    {
        [self logError:@"sqlite3_prepare_v2 failed for \"selectCategories\" with return code %d",result];
        handler (nil);
    }
    
    NSMutableArray * dbOrders = [[NSMutableArray alloc] init];
    
    while ( sqlite3_step ( selectStatement ) == SQLITE_ROW )
    {
        int tourID = (int)    sqlite3_column_int  ( selectStatement, 0 );
        
        NSNumber *idTour = [NSNumber numberWithInt:tourID];
        
        [dbOrders addObject:idTour];
    }
    sqlite3_finalize ( selectStatement );
    
    if ( dbOrders.count )
    {
        handler ( dbOrders );
    }else{
        handler (nil);
    }
}
-(void)deleteTourSight:(int)tourid withType:(NSString*)type{
    if ( ! dbIsOK )
    {
        return;
    }
    sqlite3_stmt * deleteStatement;
    int result = sqlite3_prepare_v2 ( tktDB, [[NSString stringWithFormat:deleteToursSights,tourid,type] UTF8String], -1, & deleteStatement, NULL );
    
    if ( result != SQLITE_OK )
    {
        [self logError:@"sqlite3_prepare_v2 failed for \"deleteCategories\" with return code %d",result];
        return;
    }
    
    result = sqlite3_step (deleteStatement);
    if ( result != SQLITE_DONE )
    {
        [self logError:@"sqlite3_step failed for \"deleteCategories\" with return code %d",result];
    }
    sqlite3_finalize ( deleteStatement );
}
-(void)deleteSightTour:(int)sightid withType:(NSString*)type{
    if ( ! dbIsOK )
    {
        return;
    }
    sqlite3_stmt * deleteStatement;
    int result = sqlite3_prepare_v2 ( tktDB, [[NSString stringWithFormat:deleteSightsTours,sightid,type] UTF8String], -1, & deleteStatement, NULL );
    
    if ( result != SQLITE_OK )
    {
        [self logError:@"sqlite3_prepare_v2 failed for \"deleteCategories\" with return code %d",result];
        return;
    }
    
    result = sqlite3_step (deleteStatement);
    if ( result != SQLITE_DONE )
    {
        [self logError:@"sqlite3_step failed for \"deleteCategories\" with return code %d",result];
    }
    sqlite3_finalize ( deleteStatement );
}

#pragma mark - TourFilters

-(void)setTourFilter:(NSArray<FilterModel *> *)tours needDelete:(BOOL)delete{
    if ( ! dbIsOK )
    {
        return;
    }
    if(delete){
        [self deleteAllTourFilter];
    }else{
        for ( FilterModel * shop in tours )
        {
            [self deleteTourFilter:[shop.filterID intValue]];
        }
    }
    for ( FilterModel * shop in tours )
    {
        sqlite3_stmt * insertStatement;
        
        NSString * insertCategory = [NSString stringWithFormat:insertTourFilter, [shop.filterID intValue],
                                     shop.title,
                                     [shop.date timeIntervalSince1970]
                                     ];
        int result = sqlite3_prepare_v2 ( tktDB, [insertCategory UTF8String], -1, & insertStatement, NULL );
        if ( result == SQLITE_OK )
        {
            result = sqlite3_step (insertStatement);
            if ( result != SQLITE_DONE )
            {
                [self logError:@"sqlite3_step failed for \"insertCategory\""];
                [self logDBError:result];
            }
        }
        else
        {
            [self logError:@"sqlite3_prepare_v2 failed for \"insertCategory\""];
            [self logDBError:result];
        }
        sqlite3_finalize ( insertStatement );
    }
}
-(void)selectTourFilter:(int)sightID withHandle:(void (^)(FilterModel*))handler{
    if ( ! dbIsOK )
    {
        handler(nil);
        return;
    }
    sqlite3_stmt * selectStatement;
    int result = sqlite3_prepare_v2 ( tktDB, [[NSString stringWithFormat:selectTourFilterWithID,sightID] UTF8String], -1, & selectStatement, NULL );
    if ( result != SQLITE_OK )
    {
        [self logError:@"sqlite3_prepare_v2 failed for \"selectCategories\" with return code %d",result];
        handler (nil);
    }
    
    FilterModel * restaurant;
    
    while ( sqlite3_step ( selectStatement ) == SQLITE_ROW )
    {
        restaurant = [[FilterModel alloc] init];
        int filterID = (int)    sqlite3_column_int  ( selectStatement, 0 );
        char * title       = (char*)    sqlite3_column_text  ( selectStatement, 1 );
        int    date = (int)    sqlite3_column_int  ( selectStatement, 2 );
        restaurant.filterID = [NSNumber numberWithInt:filterID];
        restaurant.title = [NSString stringWithString:[NSString stringWithUTF8String:title]];
        restaurant.date = [NSDate dateWithTimeIntervalSince1970:date];
    }
    sqlite3_finalize ( selectStatement );
    
    if ( restaurant )
    {
        handler ( restaurant );
    }
    
}
-(void)selectTourFilter:(void (^)(NSArray<FilterModel *> *))handler{
    if ( ! dbIsOK )
    {
        handler(nil);
        return;
    }
    sqlite3_stmt * selectStatement;
    int result = sqlite3_prepare_v2 ( tktDB, [selectTourFilter UTF8String], -1, & selectStatement, NULL );
    if ( result != SQLITE_OK )
    {
        [self logError:@"sqlite3_prepare_v2 failed for \"selectCategories\" with return code %d",result];
        handler (nil);
    }
    
    NSMutableArray * dbOrders = [[NSMutableArray alloc] init];
    
    while ( sqlite3_step ( selectStatement ) == SQLITE_ROW )
    {
        int filterID = (int)    sqlite3_column_int  ( selectStatement, 0 );
        char * title       = (char*)    sqlite3_column_text  ( selectStatement, 1 );
        int    date = (int)    sqlite3_column_int  ( selectStatement, 2 );
        FilterModel * restaurant = [[FilterModel alloc] init];
        restaurant.filterID = [NSNumber numberWithInt:filterID];
        restaurant.title = [NSString stringWithString:[NSString stringWithUTF8String:title]];
        restaurant.date = [NSDate dateWithTimeIntervalSince1970:date];
        [dbOrders addObject:restaurant];
    }
    sqlite3_finalize ( selectStatement );
    
    if ( dbOrders.count )
    {
        handler ( dbOrders );
    }else{
        handler (nil);
    }
}

-(void)deleteAllTourFilter{
    if ( ! dbIsOK )
    {
        return;
    }
    
    sqlite3_stmt * deleteStatement;
    int result = sqlite3_prepare_v2 ( tktDB, [deleteTourFilter UTF8String], -1, & deleteStatement, NULL );
    
    if ( result != SQLITE_OK )
    {
        [self logError:@"sqlite3_prepare_v2 failed for \"deleteCategories\" with return code %d",result];
        return;
    }
    
    result = sqlite3_step (deleteStatement);
    if ( result != SQLITE_DONE )
    {
        [self logError:@"sqlite3_step failed for \"deleteCategories\" with return code %d",result];
    }
    sqlite3_finalize ( deleteStatement );
}
-(void)deleteTourFilter:(int)sightID{
    if ( ! dbIsOK )
    {
        return;
    }
    
    sqlite3_stmt * deleteStatement;
    int result = sqlite3_prepare_v2 ( tktDB, [[NSString stringWithFormat:deleteTourFilterWithID,sightID] UTF8String], -1, & deleteStatement, NULL );
    
    if ( result != SQLITE_OK )
    {
        [self logError:@"sqlite3_prepare_v2 failed for \"deleteCategories\" with return code %d",result];
        return;
    }
    
    result = sqlite3_step (deleteStatement);
    if ( result != SQLITE_DONE )
    {
        [self logError:@"sqlite3_step failed for \"deleteCategories\" with return code %d",result];
    }
    sqlite3_finalize ( deleteStatement );
}
#pragma mark - SightFilters

-(void)setSightFilter:(NSArray<FilterModel *> *)tours needDelete:(BOOL)delete{
    if ( ! dbIsOK )
    {
        return;
    }
    if(delete){
        [self deleteAllSightFilter];
    }else{
        for ( FilterModel * shop in tours )
        {
            [self deleteSightFilter:[shop.filterID intValue]];
        }
    }
    for ( FilterModel * shop in tours )
    {
        sqlite3_stmt * insertStatement;
        
        NSString * insertCategory = [NSString stringWithFormat:insertSightFilter, [shop.filterID intValue],
                                     shop.title,
                                     [shop.date timeIntervalSince1970]
                                     ];
        int result = sqlite3_prepare_v2 ( tktDB, [insertCategory UTF8String], -1, & insertStatement, NULL );
        if ( result == SQLITE_OK )
        {
            result = sqlite3_step (insertStatement);
            if ( result != SQLITE_DONE )
            {
                [self logError:@"sqlite3_step failed for \"insertCategory\""];
                [self logDBError:result];
            }
        }
        else
        {
            [self logError:@"sqlite3_prepare_v2 failed for \"insertCategory\""];
            [self logDBError:result];
        }
        sqlite3_finalize ( insertStatement );
    }
}
-(void)selectSightFilter:(int)sightID withHandle:(void (^)(FilterModel*))handler{
    if ( ! dbIsOK )
    {
        handler(nil);
        return;
    }
    sqlite3_stmt * selectStatement;
    int result = sqlite3_prepare_v2 ( tktDB, [[NSString stringWithFormat:selectSightFilterWithID,sightID] UTF8String], -1, & selectStatement, NULL );
    if ( result != SQLITE_OK )
    {
        [self logError:@"sqlite3_prepare_v2 failed for \"selectCategories\" with return code %d",result];
        handler (nil);
    }
    
    FilterModel * restaurant;
    
    while ( sqlite3_step ( selectStatement ) == SQLITE_ROW )
    {
        restaurant = [[FilterModel alloc] init];
        int filterID = (int)    sqlite3_column_int  ( selectStatement, 0 );
        char * title       = (char*)    sqlite3_column_text  ( selectStatement, 1 );
        int    date = (int)    sqlite3_column_int  ( selectStatement, 2 );
        restaurant.filterID = [NSNumber numberWithInt:filterID];
        restaurant.title = [NSString stringWithString:[NSString stringWithUTF8String:title]];
        restaurant.date = [NSDate dateWithTimeIntervalSince1970:date];
    }
    sqlite3_finalize ( selectStatement );
    
    if ( restaurant )
    {
        handler ( restaurant );
    }
    
}
-(void)selectSightFilter:(void (^)(NSArray<FilterModel *> *))handler{
    if ( ! dbIsOK )
    {
        handler(nil);
        return;
    }
    sqlite3_stmt * selectStatement;
    int result = sqlite3_prepare_v2 ( tktDB, [selectSightFilter UTF8String], -1, & selectStatement, NULL );
    if ( result != SQLITE_OK )
    {
        [self logError:@"sqlite3_prepare_v2 failed for \"selectCategories\" with return code %d",result];
        handler (nil);
    }
    
    NSMutableArray * dbOrders = [[NSMutableArray alloc] init];
    
    while ( sqlite3_step ( selectStatement ) == SQLITE_ROW )
    {
        int filterID = (int)    sqlite3_column_int  ( selectStatement, 0 );
        char * title       = (char*)    sqlite3_column_text  ( selectStatement, 1 );
        int    date = (int)    sqlite3_column_int  ( selectStatement, 2 );
        FilterModel * restaurant = [[FilterModel alloc] init];
        restaurant.filterID = [NSNumber numberWithInt:filterID];
        restaurant.title = [NSString stringWithString:[NSString stringWithUTF8String:title]];
        restaurant.date = [NSDate dateWithTimeIntervalSince1970:date];
        [dbOrders addObject:restaurant];
    }
    sqlite3_finalize ( selectStatement );
    
    if ( dbOrders.count )
    {
        handler ( dbOrders );
    }else{
        handler (nil);
    }
}

-(void)deleteAllSightFilter{
    if ( ! dbIsOK )
    {
        return;
    }
    
    sqlite3_stmt * deleteStatement;
    int result = sqlite3_prepare_v2 ( tktDB, [deleteSightFilter UTF8String], -1, & deleteStatement, NULL );
    
    if ( result != SQLITE_OK )
    {
        [self logError:@"sqlite3_prepare_v2 failed for \"deleteCategories\" with return code %d",result];
        return;
    }
    
    result = sqlite3_step (deleteStatement);
    if ( result != SQLITE_DONE )
    {
        [self logError:@"sqlite3_step failed for \"deleteCategories\" with return code %d",result];
    }
    sqlite3_finalize ( deleteStatement );
}
-(void)deleteSightFilter:(int)sightID{
    if ( ! dbIsOK )
    {
        return;
    }
    
    sqlite3_stmt * deleteStatement;
    int result = sqlite3_prepare_v2 ( tktDB, [[NSString stringWithFormat:deleteSightFilterWithID,sightID] UTF8String], -1, & deleteStatement, NULL );
    
    if ( result != SQLITE_OK )
    {
        [self logError:@"sqlite3_prepare_v2 failed for \"deleteCategories\" with return code %d",result];
        return;
    }
    
    result = sqlite3_step (deleteStatement);
    if ( result != SQLITE_DONE )
    {
        [self logError:@"sqlite3_step failed for \"deleteCategories\" with return code %d",result];
    }
    sqlite3_finalize ( deleteStatement );
}

#pragma mark - FilterHelper

-(void)setFilterHelper:(NSString*)type sightID:(int)idSight filterID:(NSArray<FilterModel*>*)idFilter{
    if ( ! dbIsOK )
    {
        return;
    }
    [self deleteFilterHelper:type witID:idSight];
    for ( FilterModel * shop in idFilter )
    {
        sqlite3_stmt * insertStatement;
        
        NSString * insertCategory = [NSString stringWithFormat:insertSightFilterWithParams, type,
                                     idSight,
                                     [shop.filterID intValue]
                                     ];
        int result = sqlite3_prepare_v2 ( tktDB, [insertCategory UTF8String], -1, & insertStatement, NULL );
        if ( result == SQLITE_OK )
        {
            result = sqlite3_step (insertStatement);
            if ( result != SQLITE_DONE )
            {
                [self logError:@"sqlite3_step failed for \"insertCategory\""];
                [self logDBError:result];
            }
        }
        else
        {
            [self logError:@"sqlite3_prepare_v2 failed for \"insertCategory\""];
            [self logDBError:result];
        }
        sqlite3_finalize ( insertStatement );
    }
}

-(void)selectFilterHelper:(int)sightID wihtType:(NSString*)typeSight andHandle:(void (^)(NSArray<NSNumber *> *))handler{
    if ( ! dbIsOK )
    {
        handler(nil);
        return;
    }
    sqlite3_stmt * selectStatement;
    int result = sqlite3_prepare_v2 ( tktDB, [[NSString stringWithFormat:selectSightFilterWithParams,typeSight,sightID] UTF8String], -1, & selectStatement, NULL );
    if ( result != SQLITE_OK )
    {
        [self logError:@"sqlite3_prepare_v2 failed for \"selectCategories\" with return code %d",result];
        handler (nil);
    }
    
    NSMutableArray * dbOrders = [[NSMutableArray alloc] init];
    
    while ( sqlite3_step ( selectStatement ) == SQLITE_ROW )
    {
        int    filterID = (int)    sqlite3_column_int  ( selectStatement, 2 );
        [dbOrders addObject:[NSNumber numberWithInt:filterID]];
    }
    sqlite3_finalize ( selectStatement );
    
    if ( dbOrders.count )
    {
        handler ( dbOrders );
    }else{
        handler (nil);
    }
}

-(void)deleteFilterHelper:(NSString*)filterType witID:(int)sightID{
    if ( ! dbIsOK )
    {
        return;
    }
    
    sqlite3_stmt * deleteStatement;
    int result = sqlite3_prepare_v2 ( tktDB, [[NSString stringWithFormat:deleteSightFilterWithParams,filterType,sightID] UTF8String], -1, & deleteStatement, NULL );
    
    if ( result != SQLITE_OK )
    {
        [self logError:@"sqlite3_prepare_v2 failed for \"deleteCategories\" with return code %d",result];
        return;
    }
    
    result = sqlite3_step (deleteStatement);
    if ( result != SQLITE_DONE )
    {
        [self logError:@"sqlite3_step failed for \"deleteCategories\" with return code %d",result];
    }
    sqlite3_finalize ( deleteStatement );
}

#pragma mark - City

-(void)selectCity:(int)cityID  withHandle:(void (^)(NSArray<CityModel *> *))handler{
    if ( ! dbIsOK )
    {
        handler(nil);
        return;
    }
    sqlite3_stmt * selectStatement;
    int result = sqlite3_prepare_v2 ( tktDB, [[NSString stringWithFormat:selectCityWithId,cityID] UTF8String], -1, & selectStatement, NULL );
    if ( result != SQLITE_OK )
    {
        [self logError:@"sqlite3_prepare_v2 failed for \"selectCategories\" with return code %d",result];
        handler (nil);
    }
    
    NSMutableArray * dbOrders = [[NSMutableArray alloc] init];
    
    while ( sqlite3_step ( selectStatement ) == SQLITE_ROW )
    {
        int  cityid = (int)    sqlite3_column_int  ( selectStatement, 0 );
        char * citytitle       = (char*)    sqlite3_column_text  ( selectStatement, 1 );
        char *  keywords = (char*)    sqlite3_column_text  ( selectStatement, 2 );
        double date = (double) sqlite3_column_double (selectStatement, 3);
        char *  imagesfirst = (char*)    sqlite3_column_text  ( selectStatement, 4 );
        int  priority = (int)    sqlite3_column_int  ( selectStatement, 5 );
        double north = (double) sqlite3_column_double (selectStatement, 6);
        double south = (double) sqlite3_column_double (selectStatement, 7);
        double east = (double) sqlite3_column_double (selectStatement, 8);
        double west = (double) sqlite3_column_double (selectStatement, 9);
        
        CityModel * restaurant = [[CityModel alloc] init];
        
        restaurant.cityID = [NSNumber numberWithInt:cityid];
        restaurant.cityTitle = [NSString stringWithString:[NSString stringWithUTF8String:citytitle]];
        restaurant.keywords = [NSString stringWithString:[NSString stringWithUTF8String:keywords]];
        restaurant.date = [NSDate dateWithTimeIntervalSince1970:date];
        restaurant.imagesFirst = [NSString stringWithString:[NSString stringWithUTF8String:imagesfirst]];
        restaurant.priority = priority;
        restaurant.north = north;
        restaurant.south = south;
        restaurant.east = east;
        restaurant.west = west;
        
        [self selectImageByType:@"city" andObjID:restaurant.cityID withHandle:^(NSArray<NSString *> *images) {
            restaurant.images = [[NSMutableArray alloc] initWithArray:images];
        }];
        
        [dbOrders addObject:restaurant];
    }
    sqlite3_finalize ( selectStatement );
    
    if ( dbOrders.count )
    {
        handler ( dbOrders );
    }else{
        handler (nil);
    }
}
-(void)selectCity:(void (^)(NSArray<CityModel *> *))handler{
    if ( ! dbIsOK )
    {
        handler(nil);
        return;
    }
    sqlite3_stmt * selectStatement;
    int result = sqlite3_prepare_v2 ( tktDB, [selectCity UTF8String], -1, & selectStatement, NULL );
    if ( result != SQLITE_OK )
    {
        [self logError:@"sqlite3_prepare_v2 failed for \"selectCategories\" with return code %d",result];
        handler (nil);
    }
    
    NSMutableArray * dbOrders = [[NSMutableArray alloc] init];
    
    while ( sqlite3_step ( selectStatement ) == SQLITE_ROW )
    {
        int  cityid = (int)    sqlite3_column_int  ( selectStatement, 0 );
        char * citytitle       = (char*)    sqlite3_column_text  ( selectStatement, 1 );
        char *  keywords = (char*)    sqlite3_column_text  ( selectStatement, 2 );
        double date = (double) sqlite3_column_double (selectStatement, 3);
        char *  imagesfirst = (char*)    sqlite3_column_text  ( selectStatement, 4 );
        int  priority = (int)    sqlite3_column_int  ( selectStatement, 5 );
        double north = (double) sqlite3_column_double (selectStatement, 6);
        double south = (double) sqlite3_column_double (selectStatement, 7);
        double east = (double) sqlite3_column_double (selectStatement, 8);
        double west = (double) sqlite3_column_double (selectStatement, 9);

        CityModel * restaurant = [[CityModel alloc] init];

        restaurant.cityID = [NSNumber numberWithInt:cityid];
        restaurant.cityTitle = [NSString stringWithString:[NSString stringWithUTF8String:citytitle]];
        restaurant.keywords = [NSString stringWithString:[NSString stringWithUTF8String:keywords]];
        restaurant.date = [NSDate dateWithTimeIntervalSince1970:date];
        restaurant.imagesFirst = [NSString stringWithString:[NSString stringWithUTF8String:imagesfirst]];
        restaurant.priority = priority;
        restaurant.north = north;
        restaurant.south = south;
        restaurant.east = east;
        restaurant.west = west;
        
        [self selectImageByType:@"city" andObjID:restaurant.cityID withHandle:^(NSArray<NSString *> *images) {
            restaurant.images = [[NSMutableArray alloc] initWithArray:images];
        }];
        
        [dbOrders addObject:restaurant];
    }
    sqlite3_finalize ( selectStatement );
    
    if ( dbOrders.count )
    {
        handler ( dbOrders );
    }else{
        handler (nil);
    }
}
-(void)setCity:(NSArray<CityModel *> *)city needDelete:(BOOL)delete{
    if ( ! dbIsOK )
    {
        return;
    }
    if (delete) {
        [self deleteAllCity];
    }else{
        for ( CityModel * shop in city )
        {
            [self deleteCity:[shop.cityID intValue]];
        }
        
    }
    for ( CityModel * page in city )
    {
        sqlite3_stmt * insertStatement;
        
        NSString * insertCategory = [NSString stringWithFormat:insertCity, [page.cityID intValue],
                                     page.cityTitle,
                                     page.keywords,
                                     [page.date timeIntervalSince1970],
                                     page.imagesFirst,
                                     page.priority,
                                     page.north,
                                     page.south,
                                     page.east,
                                     page.west
                                     ];
        int result = sqlite3_prepare_v2 ( tktDB, [insertCategory UTF8String], -1, & insertStatement, NULL );
        if ( result == SQLITE_OK )
        {
            result = sqlite3_step (insertStatement);
            if ( result != SQLITE_DONE )
            {
                [self logError:@"sqlite3_step failed for \"insertCategory\""];
                [self logDBError:result];
            }
        }
        else
        {
            [self logError:@"sqlite3_prepare_v2 failed for \"insertCategory\""];
            [self logDBError:result];
        }
        sqlite3_finalize ( insertStatement );
        for (int i= 0; i<page.images.count; i++) {
            [self insertImages:@"city" withUrl:page.images[i] withID:page.cityID];
        }
    }
}
-(void)deleteCity:(int)restID{
    if ( ! dbIsOK )
    {
        return;
    }
    
    sqlite3_stmt * deleteStatement;
    int result = sqlite3_prepare_v2 ( tktDB, [[NSString stringWithFormat:deleteCityWithID,restID] UTF8String], -1, & deleteStatement, NULL );
    
    if ( result != SQLITE_OK )
    {
        [self logError:@"sqlite3_prepare_v2 failed for \"deleteCategories\" with return code %d",result];
        return;
    }
    
    result = sqlite3_step (deleteStatement);
    if ( result != SQLITE_DONE )
    {
        [self logError:@"sqlite3_step failed for \"deleteCategories\" with return code %d",result];
    }
    sqlite3_finalize ( deleteStatement );
    [self deleteImages:@"city" withID:restID];
}
-(void)deleteAllCity{
    if ( ! dbIsOK )
    {
        return;
    }
    
    sqlite3_stmt * deleteStatement;
    int result = sqlite3_prepare_v2 ( tktDB, [deleteCity UTF8String], -1, & deleteStatement, NULL );
    
    if ( result != SQLITE_OK )
    {
        [self logError:@"sqlite3_prepare_v2 failed for \"deleteCategories\" with return code %d",result];
        return;
    }
    
    result = sqlite3_step (deleteStatement);
    if ( result != SQLITE_DONE )
    {
        [self logError:@"sqlite3_step failed for \"deleteCategories\" with return code %d",result];
    }
    sqlite3_finalize ( deleteStatement );
    [self deleteImages:@"city"];
}
#pragma mark - Images
-(void)deleteImages:(NSString*)type withID:(int)objectID{
    if ( ! dbIsOK )
    {
        return;
    }
    sqlite3_stmt * deleteStatement;
    int result = sqlite3_prepare_v2 ( tktDB, [[NSString stringWithFormat:deleteImagesWithID,type,objectID] UTF8String], -1, & deleteStatement, NULL );
    
    if ( result != SQLITE_OK )
    {
        [self logError:@"sqlite3_prepare_v2 failed for \"deleteCategories\" with return code %d",result];
        return;
    }
    
    result = sqlite3_step (deleteStatement);
    if ( result != SQLITE_DONE )
    {
        [self logError:@"sqlite3_step failed for \"deleteCategories\" with return code %d",result];
    }
    sqlite3_finalize ( deleteStatement );
}
-(void)deleteImages:(NSString*)type{
    if ( ! dbIsOK )
    {
        return;
    }
    sqlite3_stmt * deleteStatement;
    int result = sqlite3_prepare_v2 ( tktDB, [[NSString stringWithFormat:deleteImages,type] UTF8String], -1, & deleteStatement, NULL );
    
    if ( result != SQLITE_OK )
    {
        [self logError:@"sqlite3_prepare_v2 failed for \"deleteCategories\" with return code %d",result];
        return;
    }
    
    result = sqlite3_step (deleteStatement);
    if ( result != SQLITE_DONE )
    {
        [self logError:@"sqlite3_step failed for \"deleteCategories\" with return code %d",result];
    }
    sqlite3_finalize ( deleteStatement );
}
-(void)insertImages:(NSString*)type withUrl:(NSString*)imgURL withID:(NSNumber*)objectID{
    if ( ! dbIsOK )
    {
        return;
    }
    sqlite3_stmt * insertStatement;
    NSString * insertCategory = [NSString stringWithFormat:insertImages,type,
                                 imgURL,
                                 [objectID intValue]
                                 ];
    int result = sqlite3_prepare_v2 ( tktDB, [insertCategory UTF8String], -1, & insertStatement, NULL );
    if ( result == SQLITE_OK )
    {
        result = sqlite3_step (insertStatement);
        if ( result != SQLITE_DONE )
        {
            [self logError:@"sqlite3_step failed for \"insertCategory\""];
            [self logDBError:result];
        }
    }
    else
    {
        [self logError:@"sqlite3_prepare_v2 failed for \"insertCategory\""];
        [self logDBError:result];
    }
    sqlite3_finalize ( insertStatement );
}
-(void)selectImageByType:(NSString*)type andObjID:(NSNumber*)objectID withHandle:(void (^)(NSArray<NSString *> *))handler{
    if ( ! dbIsOK )
    {
        handler(nil);
        return;
    }
    sqlite3_stmt * selectStatement;
    int result = sqlite3_prepare_v2 ( tktDB, [[NSString stringWithFormat:selectImages,type,[objectID intValue]] UTF8String], -1, & selectStatement, NULL );
    if ( result != SQLITE_OK )
    {
        [self logError:@"sqlite3_prepare_v2 failed for \"selectCategories\" with return code %d",result];
        handler (nil);
    }
    
    NSMutableArray * dbOrders = [[NSMutableArray alloc] init];
    
    while ( sqlite3_step ( selectStatement ) == SQLITE_ROW )
    {
        char * url = (char*)    sqlite3_column_text  ( selectStatement, 1 );
        
        NSString *urlStr = [NSString stringWithString:[NSString stringWithUTF8String:url]];
        
        [dbOrders addObject:urlStr];
    }
    sqlite3_finalize ( selectStatement );
    
    if ( dbOrders.count )
    {
        handler ( dbOrders );
    }else{
        handler (nil);
    }
}
@end


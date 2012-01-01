//
//  LocationInfo.m
//  WeatherSharing
//
//  Created by admin on 12/1/1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "LocationInfo.h"



@implementation LocationInfo


- (void)addToArray:(NSMutableArray *)array name:(char *)name identifier:(NSString *)identifier longt:(NSString *)longt lat:(NSString *)lat
{
	NSString *nameString = [NSString stringWithUTF8String:name];
	[array addObject:[NSDictionary dictionaryWithObjectsAndKeys:identifier, @"identifier", nameString, @"name",longt,@"longt",lat,@"lat", nil]];
}

- (LocationInfo *)initOBSLocations
{
    [self init];
	_OBSLocations = [[NSMutableArray alloc] init];
	
	
	[self addToArray:_OBSLocations name:"基隆" identifier:@"46694" longt:@"121.7404612356417" lat:@"25.13318217534233 "];
	[self addToArray:_OBSLocations name:"台北" identifier:@"46692" longt:@"121.5148827488518" lat:@"25.03761528020129"];	
	[self addToArray:_OBSLocations name:"板橋" identifier:@"46688" longt:@"121.4419350767222" lat:@"24.99769851892472"];
	[self addToArray:_OBSLocations name:"陽明山" identifier:@"46693" longt:@"121.5445343226169" lat:@"25.16206990277813"];
	[self addToArray:_OBSLocations name:"淡水" identifier:@"46690" longt:@"121.4489100088871" lat:@"25.16486587602338"];	
	[self addToArray:_OBSLocations name:"新店" identifier:@"A0A9M" longt:@"121.5242933272011" lat:@"24.95908978622261"];
	[self addToArray:_OBSLocations name:"桃園" identifier:@"46697" longt:@"121.230252951588" lat:@"25.07423592229775"];
    //	[self addToArray:north name:"新屋" identifier:@"C0C45""];	
	[self addToArray:_OBSLocations name:"新竹" identifier:@"46757" longt:@"121.0140935681308" lat:@"24.82773071482061"];
	[self addToArray:_OBSLocations name:"雪霸" identifier:@"C0D55" longt:@"121.124288998768" lat:@"24.52507799729624"];
	[self addToArray:_OBSLocations name:"三義" identifier:@"C0E53" longt:@"120.765956" lat:@"24.410927"];	
	[self addToArray:_OBSLocations name:"竹南" identifier:@"C0E42" longt:@"120.889034" lat:@"24.708981"];
    [self addToArray:_OBSLocations name:"三芝" identifier:@"C0AD0" longt:@"121.493364" lat:@"25.259639"];
    [self addToArray:_OBSLocations name:"坪林" identifier:@"C0A53" longt:@"121.701389" lat:@"24.939722"];
    [self addToArray:_OBSLocations name:"中壢" identifier:@"C0C52" longt:@"121.187222" lat:@"24.968889"];
    [self addToArray:_OBSLocations name:"大溪" identifier:@"C0C63" longt:@"121.256944" lat:@"24.884722"];
    [self addToArray:_OBSLocations name:"關西" identifier:@"C0D39" longt:@"121.173889" lat:@"24.798333"];
    [self addToArray:_OBSLocations name:"竹東" identifier:@"C0D56" longt:@"121.058056" lat:@"24.767500"];
    [self addToArray:_OBSLocations name:"苑里" identifier:@"C0E76" longt:@"120.671944" lat:@"24.435278"];
    
    
	[self addToArray:_OBSLocations name:"台中" identifier:@"46749" longt:@"120.6840801078669" lat:@"24.14573622352714"];
	[self addToArray:_OBSLocations name:"梧棲" identifier:@"46777" longt:@"120.523087755847" lat:@"24.25594574485395"];	
	[self addToArray:_OBSLocations name:"梨山" identifier:@"C0F86" longt:@"121.259270709179" lat:@"24.2551549722834"];
	[self addToArray:_OBSLocations name:"員林" identifier:@"C0G65"longt:@"120.585929" lat:@"23.94621600000001"];
	[self addToArray:_OBSLocations name:"鹿港" identifier:@"C0G64"longt:@"120.430379" lat:@"24.07511500000001"];	
    
	[self addToArray:_OBSLocations name:"日月潭" identifier:@"46765"longt:@"120.9079183172928" lat:@"23.88141313281474"];
	[self addToArray:_OBSLocations name:"廬山" identifier:@"C0I01"longt:@"121.1814770127766" lat:@"24.03313494185243"];
	[self addToArray:_OBSLocations name:"合歡山" identifier:@"C0H9C"longt:@"121.272592" lat:@"24.1434100000001"];	
	[self addToArray:_OBSLocations name:"虎尾" identifier:@"C0K33"longt:@"120.440637" lat:@"23.719564"];
	[self addToArray:_OBSLocations name:"草嶺" identifier:@"C0K24"longt:@"120.701466" lat:@"23.5937200000001"];
	[self addToArray:_OBSLocations name:"嘉義" identifier:@"46748"longt:@"120.4330915307886" lat:@"23.49602910270533"];	
	[self addToArray:_OBSLocations name:"阿里山" identifier:@"46753"longt:@"120.8132268451421" lat:@"23.5086294718419"];
	[self addToArray:_OBSLocations name:"玉山" identifier:@"46755"longt:@"120.959855" lat:@"23.48752900000002"];
    [self addToArray:_OBSLocations name:"大雅" identifier:@"C0F99" longt:@"120.599167" lat:@"24.220833"];
	[self addToArray:_OBSLocations name:"大城" identifier:@"C0G71" longt:@"120.271944" lat:@"23.850556"];
    [self addToArray:_OBSLocations name:"四湖" identifier:@"C0K28" longt:@"120.217222" lat:@"23.631111"];
    [self addToArray:_OBSLocations name:"竹山" identifier:@"C0I11" longt:@"120.677778" lat:@"23.764722"];
    [self addToArray:_OBSLocations name:"大埔" identifier:@"C0M41" longt:@"120.573611" lat:@"23.326389"];
    
	[self addToArray:_OBSLocations name:"台南" identifier:@"46741"longt:@"120.2047756316505" lat:@"22.99323293868776"];
	[self addToArray:_OBSLocations name:"高雄" identifier:@"46744"longt:@"120.3157349683732" lat:@"22.56598212591597"];
	[self addToArray:_OBSLocations name:"甲仙" identifier:@"C0V25"longt:@"120.590596" lat:@"23.079836"];	
	[self addToArray:_OBSLocations name:"三地門" identifier:@"C0R15"longt:@"120.639743" lat:@"22.710113"];
	[self addToArray:_OBSLocations name:"恆春" identifier:@"46759"longt:@"120.7463127501688" lat:@"22.00386748400043"];
    [self addToArray:_OBSLocations name:"柳營" identifier:@"C0O91" longt:@"120.313889" lat:@"23.294167"];
    [self addToArray:_OBSLocations name:"佳里" identifier:@"C0X08" longt:@"120.136667" lat:@"23.175000"];
    [self addToArray:_OBSLocations name:"玉井" identifier:@"C0O93" longt:@"120.452500" lat:@"23.127500"];
    [self addToArray:_OBSLocations name:"美濃" identifier:@"C0V31" longt:@"120.511111" lat:@"22.900556"];
    [self addToArray:_OBSLocations name:"田寮" identifier:@"C0V37" longt:@"120.393889" lat:@"22.895000"];
    [self addToArray:_OBSLocations name:"潮州" identifier:@"C0R22" longt:@"120.531667" lat:@"22.535278"];
    [self addToArray:_OBSLocations name:"枋山" identifier:@"C0R40" longt:@"120.684722" lat:@"22.191667"];
    
    
    
    
	[self addToArray:_OBSLocations name:"宜蘭" identifier:@"46708"longt:@"121.7563165151992" lat:@"24.76377789900459"];
	[self addToArray:_OBSLocations name:"蘇澳" identifier:@"46706"longt:@"121.8572413985895" lat:@"24.59671352178624"];
	[self addToArray:_OBSLocations name:"太平山" identifier:@"C0U71"longt:@"121.525672" lat:@"24.50533600000001"];	
	[self addToArray:_OBSLocations name:"花蓮" identifier:@"46699"longt:@"121.6130771379004" lat:@"23.97516268568213"];
	[self addToArray:_OBSLocations name:"玉里" identifier:@"C0Z06"longt:@"121.34782" lat:@"23.319797"];
	[self addToArray:_OBSLocations name:"成功" identifier:@"46761"longt:@"121.3736851376556" lat:@"23.09751180727719"];	
	[self addToArray:_OBSLocations name:"台東" identifier:@"46766"longt:@"121.1548628611948" lat:@"22.75237733493913"];
	[self addToArray:_OBSLocations name:"大武" identifier:@"46754"longt:@"120.9037969659824" lat:@"22.35582393479362"];
    [self addToArray:_OBSLocations name:"礁溪" identifier:@"C0U60" longt:@"121.759167" lat:@"24.820278"];
    [self addToArray:_OBSLocations name:"天祥" identifier:@"C0T82" longt:@"121.487500" lat:@"24.181389"];
    [self addToArray:_OBSLocations name:"鯉魚潭" identifier:@"C0T87" longt:@"121.529444" lat:@"24.907222"];
    [self addToArray:_OBSLocations name:"光復" identifier:@"C0T96" longt:@"121.416667" lat:@"23.662500"];
    [self addToArray:_OBSLocations name:"池上" identifier:@"C0S74" longt:@"121.201667" lat:@"23.121389"];
	
	[self addToArray:_OBSLocations name:"澎湖" identifier:@"46735"longt:@"119.5630634496015" lat:@"23.56522695682793"];
	[self addToArray:_OBSLocations name:"金門" identifier:@"46711"longt:@"118.2893394481258" lat:@"24.40745472408523"];
	[self addToArray:_OBSLocations name:"馬祖" identifier:@"46799"longt:@"119.9231216276579" lat:@"26.16923573156216"];	
	[self addToArray:_OBSLocations name:"綠島" identifier:@"C0S73"longt:@"121.4833379995002" lat:@"22.65201100317353"];
	[self addToArray:_OBSLocations name:"蘭嶼" identifier:@"46762"longt:@"121.5586043317149" lat:@"22.03691543312875"];
	[self addToArray:_OBSLocations name:"彭佳嶼" identifier:@"46695"longt:@"122.0794928012751" lat:@"25.62760583977913"];	
	[self addToArray:_OBSLocations name:"東吉島" identifier:@"46730"longt:@"119.6704560059028" lat:@"23.25231373039598"];
	[self addToArray:_OBSLocations name:"琉球嶼" identifier:@"C0R27"longt:@"120.3622250017928" lat:@"22.3320670050115"];

    return self;
}


- (NSArray *)OBSLocations
{
	return _OBSLocations;
}

@end

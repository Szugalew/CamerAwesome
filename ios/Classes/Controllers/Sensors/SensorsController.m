//
//  SensorsController.m
//  camerawesome
//
//  Created by Dimitri Dessus on 28/03/2023.
//

#import "SensorsController.h"
#import "Pigeon.h"

@implementation SensorsController

+ (NSArray *)getSensors:(AVCaptureDevicePosition)position {
  NSMutableArray *sensors = [NSMutableArray new];
  
  NSArray *sensorsType = @[AVCaptureDeviceTypeBuiltInTripleCamera, AVCaptureDeviceTypeBuiltInDualWideCamera, AVCaptureDeviceTypeBuiltInWideAngleCamera, AVCaptureDeviceTypeBuiltInTelephotoCamera, AVCaptureDeviceTypeBuiltInUltraWideCamera, AVCaptureDeviceTypeBuiltInTrueDepthCamera];
  
  AVCaptureDeviceDiscoverySession *discoverySession = [AVCaptureDeviceDiscoverySession
                                                       discoverySessionWithDeviceTypes:sensorsType
                                                       mediaType:AVMediaTypeVideo
                                                       position:AVCaptureDevicePositionUnspecified];
  
  bool hasWideAngle = false;
  for (AVCaptureDevice *device in discoverySession.devices) {
    PigeonSensorType type;
    if (device.deviceType == AVCaptureDeviceTypeBuiltInTelephotoCamera) {
      type = PigeonSensorTypeTelephoto;
    } else if (device.deviceType == AVCaptureDeviceTypeBuiltInUltraWideCamera) {
      type = PigeonSensorTypeUltraWideAngle;
    } else if (device.deviceType == AVCaptureDeviceTypeBuiltInTrueDepthCamera) {
      type = PigeonSensorTypeTrueDepth;
    } else if (device.deviceType == AVCaptureDeviceTypeBuiltInWideAngleCamera || device.deviceType == AVCaptureDeviceTypeBuiltInTripleCamera || device.deviceType == AVCaptureDeviceTypeBuiltInDualWideCamera) {
      type = PigeonSensorTypeWideAngle;
      if (hasWideAngle) {
        continue;
      }
      // print the fov of the constituentDevices devices
      if (device.deviceType == AVCaptureDeviceTypeBuiltInTripleCamera) {
        for (NSNumber *factor in device.virtualDeviceSwitchOverVideoZoomFactors) {
          // print factor
          NSLog(@"Device: %@, Factor: %f", device.localizedName, [factor floatValue]);
          }
        for (AVCaptureDevice *subDevice in device.constituentDevices) {
          // print fov
          NSLog(@"Device: %@, Field of view: %f", subDevice.localizedName, subDevice.activeFormat.videoFieldOfView);
        }
      }
      // print the zoom levels
      NSLog(@"Device: %@, Max zoom: %f, Min zoom: %f", device.localizedName, device.minAvailableVideoZoomFactor, device.maxAvailableVideoZoomFactor);

      hasWideAngle = true;
    } else {
      type = PigeonSensorTypeUnknown;
    }
    
    PigeonSensorTypeDevice *sensorType = [PigeonSensorTypeDevice makeWithSensorType:type name:device.localizedName iso:[NSNumber numberWithFloat:device.ISO] flashAvailable:[NSNumber numberWithBool:device.flashAvailable] uid:device.uniqueID];
    
    if (device.position == position) {
      [sensors addObject:sensorType];
    }
  }
  
  return sensors;
}

@end

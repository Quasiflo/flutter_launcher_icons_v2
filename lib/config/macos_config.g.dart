// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'macos_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MacOSConfig _$MacOSConfigFromJson(Map json) => $checkedCreate(
      'MacOSConfig',
      json,
      ($checkedConvert) {
        final val = MacOSConfig(
          generate: $checkedConvert('generate', (v) => v as bool? ?? false),
          imagePath: $checkedConvert('image_path', (v) => v as String?),
          padding: $checkedConvert('padding', (v) => (v as num?)?.toInt() ?? 0),
          roundedCorners:
              $checkedConvert('rounded_corners', (v) => v as bool? ?? false),
        );
        return val;
      },
      fieldKeyMap: const {
        'imagePath': 'image_path',
        'roundedCorners': 'rounded_corners'
      },
    );

Map<String, dynamic> _$MacOSConfigToJson(MacOSConfig instance) =>
    <String, dynamic>{
      'generate': instance.generate,
      'image_path': instance.imagePath,
      'padding': instance.padding,
      'rounded_corners': instance.roundedCorners,
    };

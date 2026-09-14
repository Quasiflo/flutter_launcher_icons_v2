// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'windows_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WindowsConfig _$WindowsConfigFromJson(Map json) => $checkedCreate(
      'WindowsConfig',
      json,
      ($checkedConvert) {
        final val = WindowsConfig(
          generate: $checkedConvert('generate', (v) => v as bool? ?? false),
          imagePath: $checkedConvert('image_path', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {'imagePath': 'image_path'},
    );

Map<String, dynamic> _$WindowsConfigToJson(WindowsConfig instance) =>
    <String, dynamic>{
      'generate': instance.generate,
      'image_path': instance.imagePath,
    };

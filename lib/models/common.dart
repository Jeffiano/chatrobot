class ConvertNumMode {
  int id = 0;
  String label = "";

  ConvertNumMode(this.id, this.label);
}

class FilterDirtyMode {
  int id = 0;
  String label = "";

  FilterDirtyMode(this.id, this.label);
}

class FilterModalMode {
  int id = 0;
  String label = "";

  FilterModalMode(this.id, this.label);
}

class VoiceType {
  int id = 0;
  String label = "";

  VoiceType(this.id, this.label);
}

class LanguageType {
  int id = 0;
  String label = "";

  LanguageType(this.id, this.label);
}

class CodecType {
  String value = "";
  String label = "";

  CodecType(this.value, this.label);
}

class ASRTriggerType {
  String value = "";
  String label = "";

  ASRTriggerType(this.value, this.label);
}

class PlayerState {
  int state = 0;
  String label = "";

  PlayerState(this.state, this.label);
}

final List<VoiceType> _voices = [
  VoiceType(1001, '智瑜(女)'),
  VoiceType(101001, "智瑜(精品-女)"),
  VoiceType(1002, "智聆(女)"),
  VoiceType(101002, "智聆(精品-女)"),
  VoiceType(1004, "智云(男)"),
  VoiceType(101004, "智云(精品-男)"),
  VoiceType(1005, "智莉(女)"),
  VoiceType(101005, "智莉(精品-女)"),
  VoiceType(101003, "智美(精品-女)"),
  VoiceType(1007, "智娜(女)"),
  VoiceType(101007, "智娜(精品-女)"),
  VoiceType(101006, "智言(精品-女)"),
  VoiceType(101014, "智宁(精品-男)"),
  VoiceType(101016, "智甜(精品-女)"),
  VoiceType(1017, "智蓉(女)"),
  VoiceType(101017, "智蓉(精品-女)"),
  VoiceType(1008, "智琪(女)"),
  VoiceType(101008, "智琪(精品-女)"),
  VoiceType(10510000, "智逍遥(男)"),
];

final List<LanguageType> _languages = [
  LanguageType(1, '中文'),
  LanguageType(2, '英文'),
];

final List<CodecType> _codecs = [
  CodecType("wav", 'wav'),
  CodecType("mp3", 'mp3'),
];

final _convert_num_mode = [
  ConvertNumMode(0, "全部转换为中文"),
  ConvertNumMode(1, "智能转换为阿拉伯数字"),
  ConvertNumMode(3, "数学相关数字转换"),
];

final _filter_dirty_mode = [
  FilterDirtyMode(0, "不过滤"),
  FilterDirtyMode(1, "过滤"),
  FilterDirtyMode(2, "替换为*"),
];

final _filter_modal_mode = [
  FilterModalMode(0, "不过滤"),
  FilterModalMode(1, "部分过滤"),
  FilterModalMode(2, "严格过滤")
];



//https://github.com/yujincheng08/BiliRoaming/blob/master/app/src/main/res/values/strings_raw.xml
//https://github.com/yujincheng08/BiliRoaming/blob/master/app/src/main/res/values/arrays.xml
enum CDNService {
  baseUrl,
  backupUrl,
  ali,
  alib,
  alio1,
  cos,
  cosb,
  coso1,
  hw,
  hwb,
  hwo1,
  hw_08c,
  hw_08h,
  hw_08ct,
  tf_hw,
  tf_tx,
  akamai,
  aliov,
  cosov,
  hwov,
  hk_bcache,
}

extension CDNServiceDesc on CDNService {
  static final List<String> _descList = [
    '基础 URL（不推荐）',
    '备用 URL',
    'ali（阿里云）',
    'alib（阿里云）',
    'alio1（阿里云）',
    'cos（腾讯云）',
    'cosb（腾讯云，VOD 加速类型）',
    'coso1（腾讯云）',
    'hw（华为云，融合 CDN）',
    'hwb（华为云，融合 CDN）',
    'hwo1（华为云，融合 CDN）',
    '08c（华为云，融合 CDN）',
    '08h（华为云，融合 CDN）',
    '08ct（华为云，融合 CDN）',
    'tf_hw（华为云）',
    'tf_tx（腾讯云）',
    'akamai（Akamai 海外）',
    'aliov（阿里云海外）',
    'cosov（腾讯云海外）',
    'hwov（华为云海外）',
    'hk_bcache（Bilibili海外）',
  ];
  String get description => _descList[index];
}

extension CDNServiceHost on CDNService {
  static final List<String> _hostList = [
    '',
    '',
    'upos-sz-mirrorali.bilivideo.com',
    'upos-sz-mirroralib.bilivideo.com',
    'upos-sz-mirroralio1.bilivideo.com',
    'upos-sz-mirrorcos.bilivideo.com',
    'upos-sz-mirrorcosb.bilivideo.com',
    'upos-sz-mirrorcoso1.bilivideo.com',
    'upos-sz-mirrorhw.bilivideo.com',
    'upos-sz-mirrorhwb.bilivideo.com',
    'upos-sz-mirrorhwo1.bilivideo.com',
    'upos-sz-mirror08c.bilivideo.com',
    'upos-sz-mirror08h.bilivideo.com',
    'upos-sz-mirror08ct.bilivideo.com',
    'upos-tf-all-hw.bilivideo.com',
    'upos-tf-all-tx.bilivideo.com',
    'upos-hz-mirrorakam.akamaized.net',
    'upos-sz-mirroraliov.bilivideo.com',
    'upos-sz-mirrorcosov.bilivideo.com',
    'upos-sz-mirrorhwov.bilivideo.com',
    'cn-hk-eq-bcache-01.bilivideo.com',
  ];
  String get host => _hostList[index];
}

extension CDNServiceCode on CDNService {
  static final List<String> _codeList = [
    'baseUrl',
    'backupUrl',
    'ali',
    'alib',
    'alio1',
    'cos',
    'cosb',
    'coso1',
    'hw',
    'hwb',
    'hwo1',
    'hw_08c',
    'hw_08h',
    'hw_08ct',
    'tf_hw',
    'tf_tx',
    'akamai',
    'aliov',
    'cosov',
    'hwov',
    'hk_bcache',
  ];
  String get code => _codeList[index];

  static CDNService? fromCode(String code) {
    final index = _codeList.indexOf(code);
    if (index != -1) {
      return CDNService.values[index];
    }
    return null;
  }
}


///
/// 扩展Kt标准函数
///
extension StandardExt on dynamic {
  dynamic let(dynamic block) => block(this);

  dynamic also(dynamic block) {
    block(this);
    return this;
  }
}

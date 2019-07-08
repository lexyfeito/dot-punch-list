abstract class Model<T> {
  int Id;
  Map<String, dynamic> toJson();

  Model(this.Id);
}
// Modelo dos itens da lista de todos:
class Item {
  String title;
  bool isDone;
  String unique;

  // Criando um constructor pro Item:
  Item({this.title, this.isDone, this.unique});  

  // Fazendo o parse de um JSON:
  Item.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    isDone = json['isDone'];
    unique = json['unique'];
  }

  // Convertendo pra JSON:
  Map<String, dynamic> toJson() {
    // Constante (final) data: 
    final Map<String, dynamic> data = new Map<String, dynamic> ();
    data['title'] = this.title;
    data['isDone'] = this.isDone;
    data['unique'] = this.unique;
    // retornando o json 'data':
    return data;
  }
}


// ----------------------------------------------------------------
// Notas de rodapé:
/* 
1.
No Javascript, criar um constructor seria algo como:
class item {
  constructor (title, isDone) {
    this.title = title,
    this.isDone = isDone
  }
}



*/
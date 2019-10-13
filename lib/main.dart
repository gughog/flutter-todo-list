import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'dart:convert';
import 'models/item.dart';

// void main() => runApp(MyApp());

void main () => runApp(App());

// Instancia principal do app:
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo List',
      debugShowCheckedModeBanner: false, // Remove o icone lateral informando  que o app está em modo de dev;
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: HomePage(),
    );
  }
}

// Widget que iŕa renderizar a pagina 'HomePage':
class HomePage extends StatefulWidget {
  // estado (lista de 'item'):
  var items = new List<Item>();

  // Construtor:
  HomePage() {
    items = [];
    // Semelhante ao Array.push() do Javascript:
    // items.add(Item(title: 'Estudar Flutter', isDone: false, unique: '1'));
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // Controller para interações do input
  var newTodoControl = new TextEditingController();

  // Seta uma chave randomica para os itens:
  String randomKey() {
    final random = new Random();
    var num = random.nextInt(1000).toString();
    return num;
  }

  // Método para add todo à lista:
  void addTodo() {
    setState(() {
      if (newTodoControl.text.isEmpty) {
        print('EMPTY FIELD');
        showDialog(
          context: context,
          builder: (BuildContext context){
            return AlertDialog(
              title: Text('Digite alguma coisa!'),
              content: Text('Você não pode adicionar um campo vazio.'),
            );
          }
        );
        return;
      } else {
        widget.items.add(
          Item(
            title: newTodoControl.text,
            isDone: false,
            unique: randomKey(),
          )
        );
        // Limpa o campo após adicionar:
        newTodoControl.text = '';
      }
      saveToStorage();
    });
  }

  // Método para remover os itens:
  void removeTodo(int index) {
    setState(() {
      widget.items.removeAt(index);
      saveToStorage();
    });

    // Mostra dialog de sucesso:
    showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text('Item removido!'),
          content: Text('O item foi removido com sucesso.'),
        );
      }
    );
  }

  // Marcar todos como "feito":
  void allDone() {
    setState(() {
      widget.items.forEach((item) => {
        item.isDone = true
      });
      saveToStorage();
    });
  }

  // Desmarcar todos os itens:
  void undoAll() {
    setState(() {
      widget.items.forEach((item) => {
        item.isDone = false
      });
      saveToStorage();
    });
  }

  void clearInput() {
    setState(() {
      newTodoControl.text = '';
    });
  }

  // Lidando com o localStorage do 'Shared Preferences':
  // "Futures" são Promises, 'async' significa que a função é assincrona;
  Future loadStorageData() async {
    var sharedPrefs = await SharedPreferences.getInstance();
    var data = sharedPrefs.getString('data');

    if (data != null) {
      Iterable decodedData = jsonDecode(data);
      List<Item> result = decodedData.map((item) => Item.fromJson(item)).toList();

      setState(() {
        widget.items = result;
      });
    }
  }

  // Salvando os dados no SharedPreferences:
  saveToStorage() async {
    var sharedPrefs = await SharedPreferences.getInstance();
    await sharedPrefs.setString('data', jsonEncode(widget.items));
  }

  // Chamamos aqui o método construtor desta classe para chamar a função
  // De loadStorage assim que a aplicação 'montar':
  _HomePageState() {
    loadStorageData();
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold representa uma página
    return Scaffold(
      // Adicionando uma barra com texto no topo:
      appBar: AppBar(
        title: Text('Lista de Tarefas'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check_box),
            color: Colors.white,
            onPressed: allDone,
          ),
          IconButton(
            icon: Icon(Icons.indeterminate_check_box),
            color: Colors.white,
            onPressed: undoAll,
          )
        ],
      ),

      // Corpo da lista:
      body: ListView.builder(
        itemCount: widget.items.length, // 'widget' para acessar o componente acima;
        itemBuilder: (BuildContext context, int index) {
          final item = widget.items[index]; // Espécie de destructuring numa constante para melhorar a legibilidade;
          // Dismissible é um item arrastável;
          return Dismissible(
            child: CheckboxListTile(
              title: Text(item.title),
              value: item.isDone,
              onChanged: (value) {
                // setState atualiza o estado (apenas em stateful widgets)
                setState((){
                  item.isDone = value;
                  saveToStorage();
                });
              },
            ),
            key: Key(item.unique),
            background: Container(
              color: Colors.red.withOpacity(0.8),
              child: Icon(
                Icons.delete,
                color: Colors.white
              ),
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 24),
            ),
            onDismissed: (direction) {
              // Aqui podemos tratar ações para caso arrastar pra esquerda ou direita;
              removeTodo(index);
            },
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        // O padding fará com que o input de texto fique visivel ao abrir o teclado; 
        child: Padding(
          child: TextFormField(
            // Controlador do input:
            controller: newTodoControl,
            // Estilos do campo de input:
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: 'Adicione um novo item...',
              hintStyle: TextStyle(
                color: Colors.white,
              ),
              contentPadding: const EdgeInsets.all(10),
              filled: true,
              fillColor: Colors.red,
              // Botoes:
              prefix: IconButton(
                icon: Icon(Icons.add),
                onPressed: addTodo,
                color: Colors.white,
                padding: const EdgeInsets.all(1),
              ),
              suffix: IconButton(
                icon: Icon(Icons.clear_all),
                onPressed: clearInput,
                color: Colors.white,
                padding: const EdgeInsets.all(1),
              ),
            ),
            style: TextStyle(
              fontSize: 22,
              color: Colors.white,
            ),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom
          ),
        ),
      ),
    );
  }
}

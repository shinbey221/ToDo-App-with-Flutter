import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:todo_app_graphql/services/graphQldata.dart';

void main() => runApp(
  GraphQLProvider(
    client: graphQlObject.client,
    child: CacheProvider(
      child: MyApp()
    ),
  )
);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(title: 'ToDo App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GraphQLClient client;
  final TextEditingController titleController = new TextEditingController();
  final TextEditingController contentController = new TextEditingController();
  initMethod(context) {
    client = GraphQLProvider.of(context).value;
  }

  Widget createDialog () {
    return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
        title: Text("Add task"),
        content: Container(
          width: 500.0,
          child: Form(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(labelText: "Title"),
                    ),
                    TextFormField(
                      maxLines: 10,
                      controller: contentController,
                      decoration: InputDecoration(labelText: "Coentent"),
                    ),
                    Center(
                        child: Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: RaisedButton(
                                elevation: 7,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                color: Colors.black,
                                onPressed: () async {
                                  await client.mutate(
                                    MutationOptions(
                                      document: addTaskMutation(
                                          titleController.text, contentController.text),
                                    ),
                                  );
                                  Navigator.pop(context);
                                  titleController.text = "";
                                  contentController.text = "";
                                },
                                child: Text(
                                  "Add",
                                  style: TextStyle(color: Colors.white),
                                )
                            )
                        )
                    )
                  ]
              )
          ),
        )
    );
  }


  Widget ToDoCard (result, index) {
    return Card (
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Flexible(
                child: Container(
                  height: MediaQuery.of(context).size.height/14.0,
                  padding: EdgeInsets.only(left: 15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Title',style: TextStyle(color: Colors.grey),),
                      Text(
                        result.data["todo"][index]["title"],
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 17.0),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Flexible(
                child: Container(
                  height: MediaQuery.of(context).size.height/14.0,
                  padding: EdgeInsets.only(left: 15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Content',style: TextStyle(color: Colors.grey),),
                      Text(
                        result.data["todo"][index]["content"],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 15.0),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Checkbox(
                value: result.data["todo"][index]["isCompleted"],
                onChanged: (bool value) async {
                    await client.mutate(
                      MutationOptions(
                        document: changeCompletedMutation(
                            result, index),
                      ),
                    );
                 },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () async{
                  await client.mutate(
                    MutationOptions(
                      document: deleteTaskMutation(
                          result, index),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => initMethod(context));
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Query(
          options: QueryOptions(document: fetchQuery(), pollInterval: 1),
          builder: (QueryResult result, {VoidCallback refetch}) {
            if (result.data == null) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(
              itemCount: result.data["todo"].length,
              itemBuilder: (BuildContext context, int index) {
                return ToDoCard(result, index);
              }
            );
          }
        )
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "Tag",
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context1) {
                return createDialog();
              }
           );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class GraphQlObject {
  static HttpLink httpLink = HttpLink(
    uri: 'https://flutter-todo-app-hasura.herokuapp.com/v1/graphql',
  );
  static Link link = httpLink as Link;
  ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      cache: InMemoryCache(),
      link: link,
    ),
  );
}

GraphQlObject graphQlObject = new GraphQlObject();

String updateCompletedMutation(result, index) {
  return (
      """mutation ToggleTask{
           update_todo(where: {
            id: {_eq: ${result.data["todo"][index]["id"]}}},
            _set: {isCompleted: ${!result.data["todo"][index]["isCompleted"]}}) {
               returning {isCompleted } 
           }
      }"""
  );
}

String deleteTaskMutation(result, index) {
  return (
      """mutation DeleteTask{       
            delete_todo(
               where: {id: {_eq: ${result.data["todo"][index]["id"]}}}
            ) { returning {id} }
      }"""
  );
}

String addTaskMutation(title, content) {
  print(title);
  print(content);
  return (
      """mutation AddTask{
            insert_todo(objects: {content: "$content", isCompleted: false, title: "$title"}) {
              returning {
                id
              }
            }
      }"""
  );
}

String fetchQuery() {
  return (
      """query TodoGet{
           todo {
              title
              content
              isCompleted
              id
           }
      } """
  );
}
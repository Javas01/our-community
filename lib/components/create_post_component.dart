import 'package:flutter/material.dart';

class CreatePostModal extends StatelessWidget {
  const CreatePostModal({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      color: Colors.redAccent,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
            child: Column(
          children: [
            Text(
              "Create New Post",
              style: Theme.of(context)
                  .textTheme
                  .headline5!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextFormField(
                decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.title),
                    contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                    hintText: 'Title',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 10),
            TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                minLines: 9,
                decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.description),
                    hintText: 'Description',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: () {}, child: const Text('Cancel')),
                const SizedBox(width: 20),
                ElevatedButton(onPressed: () {}, child: const Text('Submit'))
              ],
            )
          ],
        )),
      ),
    );
  }
}

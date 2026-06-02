import 'package:flutter/material.dart';

class Dog {
  final String name;
  final String breed;
  final String image;

  const Dog({required this.name, required this.breed, required this.image});
}

const List<Dog> allDogs = [
  Dog(name: 'Buddy',   breed: 'Golden Retriever', image: 'assets/dog_golden.png'),
  Dog(name: 'Rex',     breed: 'German Shepherd',  image: 'assets/dog_shepherd.png'),
  Dog(name: 'Bruno',   breed: 'Bulldog',          image: 'assets/dog_bulldog.png'),
  Dog(name: 'Coco',    breed: 'Poodle',           image: 'assets/dog_poodle.png'),
  Dog(name: 'Storm',   breed: 'Husky',            image: 'assets/dog_husky.png'),
];

class PetProfileScreen extends StatefulWidget {
  final Dog selectedDog;
  final Function(Dog) onDogSelected;

  const PetProfileScreen({
    super.key,
    required this.selectedDog,
    required this.onDogSelected,
  });

  @override
  State<PetProfileScreen> createState() => _PetProfileScreenState();
}

class _PetProfileScreenState extends State<PetProfileScreen> {
  late Dog _selected;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedDog;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = allDogs
        .where((d) =>
    d.name.toLowerCase().contains(_search.toLowerCase()) ||
        d.breed.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pet Profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Column(
        children: [

          // PERRO SELECCIONADO
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    _selected.image,
                    height: 180,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _selected.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                Text(
                  _selected.breed,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // BUSCADOR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Search by name or breed...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // LISTA DE PERROS
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final dog = filtered[index];
                final isSelected = dog.breed == _selected.breed;

                return GestureDetector(
                  onTap: () => setState(() => _selected = dog),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF4CAF50)
                            : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            dog.image,
                            width: 60,
                            height: 60,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dog.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              dog.breed,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        if (isSelected)
                          const Icon(Icons.check_circle,
                              color: Color(0xFF4CAF50), size: 24),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // BOTÓN GUARDAR
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onDogSelected(_selected);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Save my pet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
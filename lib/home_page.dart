import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'api_service.dart';
import 'detail_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keripikroll', style: TextStyle(fontWeight: FontWeight.w500))),
      body: FutureBuilder<List<dynamic>>(
        future: ApiService.fetchAllAnimes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); 
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada data anime.'));
          }

          final animes = snapshot.data!;
          return ListView.builder(
            itemCount: animes.length,
            itemBuilder: (context, index) {
              final anime = animes[index];
              return ListTile(
                leading: Image.network(anime['coverImageTopOffset'], width: 80, fit: BoxFit.cover), 
                title: Text(anime['canonicalTitle']), // Nama game [cite: 48]
                subtitle: Text('${anime['ageRating']} • ${anime['episodeCount']}'), 
                trailing: const Icon(Icons.star, size: 16),
                //subtitle: Text(anime['averageRating']),
                onTap: () => Get.to(() => DetailPage(animeId: anime['id'])), // Pindah ke detail [cite: 55]
              );
            },
          );
        },
      ),
    );
  }
}
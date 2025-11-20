import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> infoList = [
      {
        'title': 'Cara Wudhu',
        'content':
            'Wudhu adalah bersuci dengan air untuk menghilangkan hadats kecil. Rukun wudhu meliputi: niat, membasuh muka, membasuh kedua tangan sampai siku, mengusap sebagian kepala, dan membasuh kedua kaki sampai mata kaki. Wudhu harus dilakukan dengan tertib sesuai urutan.',
      },
      {
        'title': 'Keutamaan Sholat',
        'content':
            'Sholat adalah tiang agama dan kewajiban pertama yang akan dihisab. Sholat tepat waktu memiliki keutamaan yang sangat besar. Sholat lima waktu dapat menghapus dosa-dosa kecil. Rasulullah SAW bersabda bahwa sholat adalah cahaya bagi mukmin.',
      },
      {
        'title': 'Doa Harian',
        'content':
            'Doa adalah senjata mukmin. Beberapa doa harian penting: doa bangun tidur, doa sebelum makan, doa sesudah makan, doa keluar rumah, doa masuk rumah, doa sebelum tidur. Membaca doa dengan khusyuk dan yakin akan dikabulkan Allah SWT.',
      },
      {
        'title': 'Adab Membaca Al-Quran',
        'content':
            'Membaca Al-Quran memiliki adab khusus: dalam keadaan suci, menghadap kiblat, membaca ta\'awudz, membaca dengan tartil, memahami makna, dan mengamalkan isi Al-Quran. Setiap huruf yang dibaca mendapat pahala.',
      },
      {
        'title': 'Keutamaan Dzikir',
        'content':
            'Dzikir adalah mengingat Allah dengan menyebut nama-Nya. Dzikir dapat menenangkan hati dan mendekatkan diri kepada Allah. Beberapa dzikir utama: tasbih, tahmid, takbir, tahlil, dan istighfar. Dzikir dapat dilakukan kapan saja.',
      },
      {
        'title': 'Puasa Sunnah',
        'content':
            'Selain puasa Ramadhan yang wajib, ada puasa sunnah yang dianjurkan: puasa Senin-Kamis, puasa Ayyamul Bidh (tanggal 13-14-15 bulan hijriyah), puasa Arafah, puasa Asyura, dan puasa Daud (sehari puasa sehari tidak).',
      },
      {
        'title': 'Sedekah',
        'content':
            'Sedekah adalah memberikan harta kepada yang berhak dengan ikhlas karena Allah. Sedekah tidak mengurangi harta, justru melipatgandakan kebaikan. Sedekah bisa berupa harta, tenaga, ilmu, atau senyuman. Sedekah terbaik adalah yang rutin walau sedikit.',
      },
      {
        'title': 'Silaturahmi',
        'content':
            'Silaturahmi adalah menyambung tali persaudaraan. Silaturahmi dapat memperpanjang umur dan melapangkan rezeki. Mulailah dengan keluarga dekat, tetangga, kemudian saudara sesama muslim. Silaturahmi bisa dilakukan dengan berkunjung atau komunikasi.',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Informasi Islami',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: infoList.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                _showDetailDialog(
                  context,
                  infoList[index]['title']!,
                  infoList[index]['content']!,
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.menu_book,
                        color: Colors.green[700],
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            infoList[index]['title']!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            infoList[index]['content']!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDetailDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.menu_book, color: Colors.green[700]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
            ),
            textAlign: TextAlign.justify,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Tutup',
              style: TextStyle(color: Colors.green[700]),
            ),
          ),
        ],
      ),
    );
  }
}
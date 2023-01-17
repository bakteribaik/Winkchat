import 'package:flutter/material.dart';
import 'package:age_calculator/age_calculator.dart';

class BannedPage extends StatefulWidget {
  const BannedPage({ Key? key }) : super(key: key);

  @override
  State<BannedPage> createState() => _BannedPageState();
}

class _BannedPageState extends State<BannedPage> {

  DateTime birtday = DateTime(2000, 10, 31);
  DateDuration duration = DateDuration();
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: SafeArea(
        child: Center(
          child: Container(
            padding: const EdgeInsets.only(left: 10, right: 10),
            width: MediaQuery.of(context).size.width/1.3,
            height: MediaQuery.of(context).size.height/2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white,
              image: const DecorationImage(
                image: NetworkImage('https://img.wallpaper.sc/desktop/images/5k/thumbnail/desktop-pc-1920x1080-thumbnail_00093.jpg'),
                fit: BoxFit.cover,
                opacity: 0.3
              ),         
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Kamu Telah di Banned!', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),),
                const Image(image: AssetImage('assets/images/banned.png'), height: 50,),           
                const Text('mohon maaf akun anda telah diban karena menyalahi terms of service dari aplikasi Snapmatch', style: TextStyle(color: Colors.grey, fontSize: 14), textAlign: TextAlign.center,),
                const SizedBox(height: 20,),
                const Text('mau ajukan banding atau perlu info lebih lanjut, silahkan hubungi', style: TextStyle(color: Colors.grey, fontSize: 10), textAlign: TextAlign.center,),
                TextButton(
                  onPressed: (){
                    duration = AgeCalculator.age(birtday);
                    print(
                      duration.years
                    );
                  },
                  child: const Text('snapmatch@gmail.com', style: TextStyle(fontSize: 12),),
                )
              ]
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sampah_emas/components/input_widget.dart';
import 'package:sampah_emas/components/styles.dart';
import 'package:sampah_emas/components/validators.dart';



class RegisterPage extends StatefulWidget{
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

  class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  String? nama;
  String? email;
  final TextEditingController _password = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  
  String? alamat;
  String? selectedProvinsi;
  String? selectedKota;
  String? selectedKecamatan;
  String? selectedKelurahan;
  String? selectedRW;
  String? selectedRT;
  int? balance;
  

  bool isSecondDropdownEnabled = false;
  bool isThirdDropdownEnabled = false;
  bool isFourthDropdownEnabled = false;
  bool isFifthDropdownEnabled = false;
  bool isSixthDropdownEnabled = false;
  List<String> secondDropdownItems = [];
  List<String> thirdDropdownItems = [];
  List<String> fourthDropdownItems = [];
  List<String> fifthDropdownItems = [];
  List<String> sixthDropdownItems = [];

  void register() async {
  setState(() {
    _isLoading = true;
  });

  try {
    // Register the user first
    final password = _password.text;
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email!, password: password);

    // Get the uid of the newly created user
    String uid = userCredential.user!.uid;

    CollectionReference akunCollection = _db.collection('akun');
    DocumentReference provinsiRef = akunCollection.doc('akun').collection('provinsi').doc(selectedProvinsi);
    DocumentReference kotaRef = provinsiRef.collection('kota').doc(selectedKota);
    DocumentReference kecamatanRef = kotaRef.collection('kecamatan').doc(selectedKecamatan);
    DocumentReference kelurahanRef = kecamatanRef.collection('kelurahan').doc(selectedKelurahan);
    DocumentReference rwRef = kelurahanRef.collection('rw').doc(selectedRW);
    DocumentReference rtRef = rwRef.collection('rt').doc(selectedRT);
    CollectionReference dataUser = rtRef.collection("data");

    // Use uid as the document ID
    final docId = uid;
    await dataUser.doc(docId).set({ 
      'uid': uid,
      'nama': nama,
      'email': email,
      'role': 'user',
      'alamat': alamat,
      'provinsi': selectedProvinsi,
      'kota': selectedKota,
      'kecamatan': selectedKecamatan,
      'kelurahan': selectedKelurahan,
      'rw': selectedRW,
      'rt': selectedRT,
      'balance': 0
    });
    
    // Adjust the user path to include the correct document structure
    String userPath = 'akun/akun/provinsi/$selectedProvinsi/kota/$selectedKota/kecamatan/$selectedKecamatan/kelurahan/$selectedKelurahan/rw/$selectedRW/rt/$selectedRT/data/$uid';

    await _db.collection('user_path').doc(uid).set({
      'uid': uid,
      'userPath': userPath,
    });

    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(
        context, '/login', ModalRoute.withName('/login'));
  } catch (e) {
    final snackbar = SnackBar(content: Text(e.toString()));
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
    print(e);
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

  void _onProvinsiChanged(String? provinsi) {
    setState(() {
      if(selectedProvinsi != provinsi){
        selectedKota = null;
        selectedKecamatan = null;
        selectedKelurahan = null;
        selectedRW = null;
        selectedRT = null;
        isThirdDropdownEnabled = false;
        isFourthDropdownEnabled = false;
        isFifthDropdownEnabled = false;
        isSixthDropdownEnabled = false;
      }

      selectedProvinsi = provinsi;
      isSecondDropdownEnabled = provinsi != null && provinsi.isNotEmpty;
      
      if (isSecondDropdownEnabled) {
      switch (provinsi) {
        case "Jawa Tengah":
          secondDropdownItems = [
            "Kota Semarang",
            "Kabupaten Semarang",
          ];
          break;
        case "Jawa Timur":
          secondDropdownItems = [
            "Kota Surabaya",
            "Kota Kediri",
          ];
          break;
        default:
          secondDropdownItems = [
            "Error Input",
            "Error Input",
            "Error Input",
            
          ];
          break;
        }
      }
      else {
        secondDropdownItems = [];
        thirdDropdownItems = [];
        fourthDropdownItems = [];
        fifthDropdownItems = [];
        sixthDropdownItems = [];
        selectedKota = null;
        selectedKecamatan = null;
        selectedKelurahan = null;
        selectedRW = null;
        selectedRT = null;
        isSecondDropdownEnabled = false;
        isThirdDropdownEnabled = false;
        isFourthDropdownEnabled = false;
        isFifthDropdownEnabled = false;
        isSixthDropdownEnabled = false;
      }
    });
  }

  void _onKotaChanged(String? kota) {
    setState(() {
      if(selectedKota != kota){
        selectedKecamatan = null;
        selectedKelurahan = null;
        selectedRW = null;
        selectedRT = null;
        isFourthDropdownEnabled = false;
        isFifthDropdownEnabled = false;
        isSixthDropdownEnabled = false;
      }

      selectedKota = kota;
      isThirdDropdownEnabled = kota != null && kota.isNotEmpty;

      if (isThirdDropdownEnabled) {
        switch (kota) {
          case "Kota Semarang":
            thirdDropdownItems = [
              "Kecamatan Pedurungan",
              "Kecamatan Tembalang",
              
            ];
            break;
          case "Kabupaten Semarang":
            thirdDropdownItems = [
              "Kecamatan Ambarawa",
              "Kecamatan Bandungan",
            ];
            break;
          case "Kota Surabaya":
            thirdDropdownItems = [
              "Kecamatan Wonokromo",
              "Kecamatan Jambangan",
            ];
            break;
          case "Kota Kediri":
            thirdDropdownItems = [
              "Kecamatan Mojoroto",
              "Kecamatan Pesantren",
            ];
            break;
          default:
            thirdDropdownItems = [
              "Error Input",
              "Error Input",
              "Error Input",
              
            ];
            break;
        }
      }
      else{
        isThirdDropdownEnabled = false;
        isFourthDropdownEnabled = false;
        isFifthDropdownEnabled = false;
        isSixthDropdownEnabled = false;
        thirdDropdownItems = [];
        fourthDropdownItems = [];
        fifthDropdownItems = [];
        sixthDropdownItems = [];
        selectedKecamatan = null;
        selectedKelurahan = null;
        selectedKota = null;
        selectedRW = null;
        selectedRT = null;
      }
    });
  }

  void _onKecamatanChanged(String? kecamatan) {
    setState(() {
      if(selectedKecamatan != kecamatan){
        selectedKelurahan = null;
        selectedRW = null;
        selectedRT = null;
        isFifthDropdownEnabled = false;
        isSixthDropdownEnabled = false;
      }

      selectedKecamatan = kecamatan;
      isFourthDropdownEnabled = kecamatan != null && kecamatan.isNotEmpty;

      if (isFourthDropdownEnabled) {
        switch (kecamatan) {
          case "Kecamatan Pedurungan":
            fourthDropdownItems = [
              "Kelurahan Tlogosari kulon",
            ];
            break;
          case "Kecamatan Tembalang":
            fourthDropdownItems = [
              "Kelurahan Tembalang",
            ];
            break;
          case "Kecamatan Ambarawa":
            fourthDropdownItems = [
              "Kelurahan Ngampin",
            ];
            break;
          case "Kecamatan Bandungan":
            fourthDropdownItems = [
              "Kelurahan Bandungan",
            ];
            break;
          case "Kecamatan Wonokromo":
            fourthDropdownItems = [
              "Kelurahan Wonokromo",
            ];
            break;
          case "Kecamatan Jambangan":
            fourthDropdownItems = [
              "Kelurahan Pagesangan",
            ];
            break;
          case "Kecamatan Mojoroto":
            fourthDropdownItems = [
              "Kelurahan Mojoroto",
            ];
            break;
          case "Kecamatan Pesantren":
            fourthDropdownItems = [
              "Kelurahan Pesantren",
            ];
            break;
          default:
            fourthDropdownItems = [
              "Error Input",
              "Error Input",
              "Error Input",
              
            ];
            break;
        }
      }
      else{
        selectedKecamatan = null;
        selectedKelurahan = null;
        selectedRW = null;
        selectedRT = null;
        isFourthDropdownEnabled = false;
        isFifthDropdownEnabled = false;
        isSixthDropdownEnabled = false;
        fourthDropdownItems = [];
        fifthDropdownItems = [];
        sixthDropdownItems = [];
      }
    });
  }

  void _onKelurahanChanged(String? kelurahan) {
    setState(() {
      if(selectedKelurahan != kelurahan){
        selectedRW = null;
        selectedRT = null;
        isSixthDropdownEnabled = false;
      }

      selectedKelurahan = kelurahan;
      isFifthDropdownEnabled = kelurahan != null && kelurahan.isNotEmpty;

      if (isFifthDropdownEnabled) {
        switch (kelurahan) {
          case "Kelurahan Tlogosari kulon":
            fifthDropdownItems = [
              "RW 01",
            ];
            break;
          case "Kelurahan Tembalang":
            fifthDropdownItems = [
              "RW 01",
            ];
            break;
          case "Kelurahan Ngampin":
            fifthDropdownItems = [
              "RW 01",
            ];
            break;
          case "Kelurahan Bandungan":
            fifthDropdownItems = [
              "RW 01",
            ];
            break;
          case "Kelurahan Wonokromo":
            fifthDropdownItems = [
              "RW 01",
            ];
            break;
          case "Kelurahan Pagesangan":
            fifthDropdownItems = [
              "RW 01",
            ];
            break;
          case "Kelurahan Mojoroto":
            fifthDropdownItems = [
              "RW 01",
            ];
            break;
          case "Kelurahan Pesantren":
            fifthDropdownItems = [
              "RW 01",
            ];
            break;
          default:
            fifthDropdownItems = [
              "Error Input",
              "Error Input",
              "Error Input",
              
            ];
            break;
        }
      }
      else{
        selectedKelurahan = null;
        selectedRW = null;
        selectedRT = null;
        isFifthDropdownEnabled = false;
        isSixthDropdownEnabled = false;
        fifthDropdownItems = [];
        sixthDropdownItems = [];
      }
    });
  }

  void _onRWChanged(String? rwVar) {
    setState(() {
      if(selectedRW != rwVar){
        selectedRT = null;
      }

      selectedRW = rwVar;
      var kelurahan = selectedKelurahan;
      isSixthDropdownEnabled = rwVar != null && rwVar.isNotEmpty;

      if (isSixthDropdownEnabled) {
        switch (kelurahan) {
          case "Kelurahan Tlogosari kulon":
            switch (rwVar) {
              case "RW 01":
                sixthDropdownItems = [
                  "RT 01",
                  "RT 02",
                  "RT 03",
                  "RT 04",
                  "RT 05",
                  "RT 06",
                ];
                break;
            }
            break;
          case "Kelurahan Tembalang":
            switch (rwVar) {
              case "RW 01":
                sixthDropdownItems = [
                  "RT 01",
                  "RT 02",
                  "RT 03",
                ];
                break;
            }
            break;
          case "Kelurahan Ngampin":
            switch (rwVar) {
              case "RW 01":
                sixthDropdownItems = [
                  "RT 01",
                  "RT 02",
                  "RT 03",
                  "RT 04",
                  "RT 05",
                ];
                break;
            }
            break;
          case "Kelurahan Bandungan":
            switch (rwVar) {
              case "RW 01":
                sixthDropdownItems = [
                  "RT 01",
                  "RT 02",
                  "RT 03",
                  "RT 04",
                ];
                break;
            }
            break;
          case "Kelurahan Wonokromo":
            switch (rwVar) {
              case "RW 01":
                sixthDropdownItems = [
                  "RT 01",
                  "RT 02",
                  "RT 03",
                ];
                break;
            }
            break;
          case "Kelurahan Pagesangan":
            switch (rwVar) {
              case "RW 01":
                sixthDropdownItems = [
                  "RT 01",
                  "RT 02",
                ];
                break;
            }
            break;
          case "Kelurahan Mojoroto":
            switch (rwVar) {
              case "RW 01":
                sixthDropdownItems = [
                  "RT 01",
                  "RT 02",
                  "RT 03",
                  "RT 04",
                  "RT 05",
                ];
                break;
            }
            break;
          case "Kelurahan Pesantren":
            switch (rwVar) {
              case "RW 01":
                sixthDropdownItems = [
                  "RT 01",
                  "RT 02",
                  "RT 03",
                  "RT 04",
                ];
                break;
            }
            break;
          default:
            sixthDropdownItems = [
              "Error Input",
              "Error Input",
              "Error Input",
              
            ];
            break;
        }
      }
      else{
        selectedRW = null;
        selectedRT = null;
        isSixthDropdownEnabled = false;
        sixthDropdownItems = [];
      }
    });
  }

  void _onRTChanged(String? rtVar) {
    setState(() {
      selectedRT = rtVar;
      if (!isSixthDropdownEnabled){
        selectedRT = null;
      }
    });
  }


@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkgreenColor,
      body: SafeArea(child: _isLoading? const Center(child: CircularProgressIndicator(),
      ):SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Register',
            style: headerStyle(level: 1, dark: false),),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 30),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    InputLayout('Nama', TextFormField(
                      onChanged: (String value) => setState(() {
                        nama = value;
                    }),
                    validator: notEmptyValidator,
                    cursorColor: Colors.white,
                    style: TextStyle(color: Colors.white),
                    decoration: customInputDecoration("Nama Lengkap"),
                    )),
                    InputLayout('Email', TextFormField(onChanged: (String value) => setState(() {
                      email = value;
                    }),
                    validator: notEmptyValidator,
                    cursorColor: Colors.white,
                    style: TextStyle(color: Colors.white),
                    decoration: customInputDecoration("email@gmail.com"),
                    )),
                    InputLayout('Alamat', TextFormField(onChanged: (String value) => setState(() {
                      alamat = value;
                    }),
                    validator: notEmptyValidator,
                    cursorColor: Colors.white,
                    style: TextStyle(color: Colors.white),
                    decoration: customInputDecoration("Jl. Sudirman Blok E No.24"),
                    )),

                    InputLayout("Provinsi",
                    DropdownSearch<String>(
                      dropdownBuilder: (context, selectedItem) {
                        return Text(
                          selectedItem ?? "Provinsi",
                          style: TextStyle(
                            color: Colors.white, // Ensure selected item text is white
                            fontWeight: selectedItem == null ? FontWeight.bold : FontWeight.normal
                          ),
                          
                        );
                      },
                      validator: notEmptyValidator,
                      items: const [
                        "Jawa Timur",
                        "Jawa Tengah",
                      ],
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: customInputDecoration("Provinsi"
                        ),
                      ),
                      
                      onChanged: _onProvinsiChanged,
                      clearButtonProps: const ClearButtonProps(
                        isVisible: true,
                        icon: Icon(Icons.clear, color: Colors.white),
                      ),
                      dropdownButtonProps: const DropdownButtonProps(
                        icon: Icon(Icons.arrow_drop_down, color: Colors.white), // Ubah warna ikon panah ke bawah
                      ),
                      
                      popupProps: PopupProps.menu(
                        showSearchBox: true,
                        
                        itemBuilder: (context, item, isSelected) {
                          return Container(
                            
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              item,
                              style: const TextStyle(
                                color: Colors.white,
                                )
                              )
                          );
                        },

                        searchFieldProps: TextFieldProps(
                          decoration: customInputDecoration("Klik disini untuk cari",
                          ),
                          cursorColor: Colors.white,
                          style: const TextStyle(
                            color: Colors.white
                          )
                        ),

                        containerBuilder: (ctx, popupWidget) {
                          return Container(
                            
                            decoration: BoxDecoration(
                              color: darkgreenColor, // Change the background color here
                              
                              borderRadius: BorderRadius.zero,
                              border: Border.all(
                                color: yellowColor, // Change the border color here
                              ),
                            ),
                            child: popupWidget,
                          );
                        },
                      ),
                      
                    )),

                    InputLayout("Kota /  Kabupaten",
                    DropdownSearch<String>(
                      enabled: isSecondDropdownEnabled,
                      items: secondDropdownItems,
                      onChanged: _onKotaChanged,
                      selectedItem: selectedKota,
                      validator: notEmptyValidator,

                      dropdownBuilder: (context, selectedItem) {
                        return Text(
                          selectedItem ?? "Kota /  Kabupaten",
                          
                          style: TextStyle(
                            color: Colors.white, // Ensure selected item text is white
                            fontWeight: selectedItem == null ? FontWeight.bold : FontWeight.normal
                          ),
                          
                        );
                      },
                      
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: customInputDecoration("Kota /  Kabupaten"
                        ),
                      ),

                      clearButtonProps: const ClearButtonProps(
                        isVisible: true,
                        icon: Icon(Icons.clear, color: Colors.white),
                      ),
                      dropdownButtonProps: const DropdownButtonProps(
                        icon: Icon(Icons.arrow_drop_down, color: Colors.white), // Ubah warna ikon panah ke bawah
                      ),
                      
                      popupProps: PopupProps.menu(
                        showSearchBox: true,
                        
                        itemBuilder: (context, item, isSelected) {
                          return Container(
                            
                            padding: EdgeInsets.all(10.0),
                            child: Text(
                              item,
                              style: const TextStyle(
                                color: Colors.white,
                                )
                              )
                          );
                        },

                        searchFieldProps: TextFieldProps(
                          decoration: customInputDecoration("Klik disini untuk cari",
                          ),
                          cursorColor: Colors.white,
                          style: const TextStyle(
                            color: Colors.white
                          )
                        ),

                        containerBuilder: (ctx, popupWidget) {
                          return Container(
                            
                            decoration: BoxDecoration(
                              color: darkgreenColor, // Change the background color here
                              
                              borderRadius: BorderRadius.zero,
                              border: Border.all(
                                color: yellowColor, // Change the border color here
                              ),
                            ),
                            child: popupWidget,
                          );
                        },
                      ),

                    )),

                    InputLayout("Kecamatan",
                    DropdownSearch<String>(
                      enabled: isThirdDropdownEnabled,
                      items: thirdDropdownItems,
                      onChanged:_onKecamatanChanged,
                      selectedItem: selectedKecamatan,
                      validator: notEmptyValidator,

                      dropdownBuilder: (context, selectedItem) {
                        return Text(
                          selectedItem ?? "Kecamatan",
                          
                          style: TextStyle(
                            color: Colors.white, // Ensure selected item text is white
                            fontWeight: selectedItem == null ? FontWeight.bold : FontWeight.normal
                          ),
                          
                        );
                      },
                      
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: customInputDecoration("Kecamatan"
                        ),
                      ),

                      clearButtonProps: const ClearButtonProps(
                        isVisible: true,
                        icon: Icon(Icons.clear, color: Colors.white),
                      ),
                      dropdownButtonProps: const DropdownButtonProps(
                        icon: Icon(Icons.arrow_drop_down, color: Colors.white), // Ubah warna ikon panah ke bawah
                      ),
                      
                      popupProps: PopupProps.menu(
                        showSearchBox: true,
                        
                        itemBuilder: (context, item, isSelected) {
                          return Container(
                            
                            padding: EdgeInsets.all(10.0),
                            child: Text(
                              item,
                              style: const TextStyle(
                                color: Colors.white,
                                )
                              )
                          );
                        },

                        searchFieldProps: TextFieldProps(
                          decoration: customInputDecoration("Klik disini untuk cari",
                          ),
                          cursorColor: Colors.white,
                          style: const TextStyle(
                            color: Colors.white
                          )
                        ),

                        containerBuilder: (ctx, popupWidget) {
                          return Container(
                            
                            decoration: BoxDecoration(
                              color: darkgreenColor, // Change the background color here
                              
                              borderRadius: BorderRadius.zero,
                              border: Border.all(
                                color: yellowColor, // Change the border color here
                              ),
                            ),
                            child: popupWidget,
                          );
                        },
                      ),

                    )),

                    InputLayout("Kelurahan",
                    DropdownSearch<String>(
                      enabled: isFourthDropdownEnabled,
                      items: fourthDropdownItems,
                      onChanged: _onKelurahanChanged,
                      selectedItem: selectedKelurahan,
                      validator: notEmptyValidator,

                      dropdownBuilder: (context, selectedItem) {
                        return Text(
                          selectedItem ?? "Kelurahan",
                          
                          style: TextStyle(
                            color: Colors.white, // Ensure selected item text is white
                            fontWeight: selectedItem == null ? FontWeight.bold : FontWeight.normal
                          ),
                          
                        );
                      },
                      
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: customInputDecoration("Kelurahan"
                        ),
                      ),

                      clearButtonProps: const ClearButtonProps(
                        isVisible: true,
                        icon: Icon(Icons.clear, color: Colors.white),
                      ),
                      dropdownButtonProps: const DropdownButtonProps(
                        icon: Icon(Icons.arrow_drop_down, color: Colors.white), // Ubah warna ikon panah ke bawah
                      ),
                      
                      popupProps: PopupProps.menu(
                        showSearchBox: true,
                        
                        itemBuilder: (context, item, isSelected) {
                          return Container(
                            
                            padding: EdgeInsets.all(10.0),
                            child: Text(
                              item,
                              style: const TextStyle(
                                color: Colors.white,
                                )
                              )
                          );
                        },

                        searchFieldProps: TextFieldProps(
                          decoration: customInputDecoration("Klik disini untuk cari",
                          ),
                          cursorColor: Colors.white,
                          style: const TextStyle(
                            color: Colors.white
                          )
                        ),

                        containerBuilder: (ctx, popupWidget) {
                          return Container(
                            
                            decoration: BoxDecoration(
                              color: darkgreenColor, // Change the background color here
                              
                              borderRadius: BorderRadius.zero,
                              border: Border.all(
                                color: yellowColor, // Change the border color here
                              ),
                            ),
                            child: popupWidget,
                          );
                        },
                      ),

                    )),

                    InputLayout("RW",
                    DropdownSearch<String>(
                      enabled: isFifthDropdownEnabled,
                      items: fifthDropdownItems,
                      onChanged: _onRWChanged,
                      selectedItem: selectedRW,
                      validator: notEmptyValidator,

                      dropdownBuilder: (context, selectedItem) {
                        return Text(
                          selectedItem ?? "RW",
                          
                          style: TextStyle(
                            color: Colors.white, // Ensure selected item text is white
                            fontWeight: selectedItem == null ? FontWeight.bold : FontWeight.normal
                          ),
                          
                        );
                      },
                      
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: customInputDecoration("RW"
                        ),
                      ),

                      clearButtonProps: const ClearButtonProps(
                        isVisible: true,
                        icon: Icon(Icons.clear, color: Colors.white),
                      ),
                      dropdownButtonProps: const DropdownButtonProps(
                        icon: Icon(Icons.arrow_drop_down, color: Colors.white), // Ubah warna ikon panah ke bawah
                      ),
                      
                      popupProps: PopupProps.menu(
                        showSearchBox: true,
                        
                        itemBuilder: (context, item, isSelected) {
                          return Container(
                            
                            padding: EdgeInsets.all(10.0),
                            child: Text(
                              item,
                              style: const TextStyle(
                                color: Colors.white,
                                )
                              )
                          );
                        },

                        searchFieldProps: TextFieldProps(
                          decoration: customInputDecoration("Klik disini untuk cari",
                          ),
                          cursorColor: Colors.white,
                          style: const TextStyle(
                            color: Colors.white
                          )
                        ),

                        containerBuilder: (ctx, popupWidget) {
                          return Container(
                            
                            decoration: BoxDecoration(
                              color: darkgreenColor, // Change the background color here
                              
                              borderRadius: BorderRadius.zero,
                              border: Border.all(
                                color: yellowColor, // Change the border color here
                              ),
                            ),
                            child: popupWidget,
                          );
                        },
                      ),

                    )),

                    InputLayout("RT",
                    DropdownSearch<String>(
                      enabled: isSixthDropdownEnabled,
                      items: sixthDropdownItems,
                      onChanged: _onRTChanged,
                      selectedItem: selectedRT,
                      validator: notEmptyValidator,

                      dropdownBuilder: (context, selectedItem) {
                        return Text(
                          selectedItem ?? "RT",
                          
                          style: TextStyle(
                            color: Colors.white, // Ensure selected item text is white
                            fontWeight: selectedItem == null ? FontWeight.bold : FontWeight.normal
                          ),
                          
                        );
                      },
                      
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: customInputDecoration("RT"
                        ),
                      ),

                      clearButtonProps: const ClearButtonProps(
                        isVisible: true,
                        icon: Icon(Icons.clear, color: Colors.white),
                      ),
                      dropdownButtonProps: const DropdownButtonProps(
                        icon: Icon(Icons.arrow_drop_down, color: Colors.white), // Ubah warna ikon panah ke bawah
                      ),
                      
                      popupProps: PopupProps.menu(
                        showSearchBox: true,
                        
                        itemBuilder: (context, item, isSelected) {
                          return Container(
                            
                            padding: EdgeInsets.all(10.0),
                            child: Text(
                              item,
                              style: const TextStyle(
                                color: Colors.white,
                                )
                              )
                          );
                        },

                        searchFieldProps: TextFieldProps(
                          decoration: customInputDecoration("Klik disini untuk cari",
                          ),
                          cursorColor: Colors.white,
                          style: const TextStyle(
                            color: Colors.white
                          )
                        ),

                        containerBuilder: (ctx, popupWidget) {
                          return Container(
                            
                            decoration: BoxDecoration(
                              color: darkgreenColor, // Change the background color here
                              
                              borderRadius: BorderRadius.zero,
                              border: Border.all(
                                color: yellowColor, // Change the border color here
                              ),
                            ),
                            child: popupWidget,
                          );
                        },
                      ),

                    )),

                    InputLayout('Password', 
                    TextFormField(
                      
                      cursorColor: Colors.white,
                      style: TextStyle(color: Colors.white),
                      controller: _password,
                      validator: notEmptyValidator,
                      obscureText: true,
                      decoration: customInputDecoration(""),
                  
                    )),
                    InputLayout('Konfirmasi Password', 
                    TextFormField(
                      validator: (value) =>
                      passConfirmationValidator(value, _password), 
                      obscureText: true,
                      cursorColor: Colors.white,
                      style: TextStyle(color: Colors.white),
                      decoration: customInputDecoration(""),
                  
                    )),
                    

                    Container(
                      margin: EdgeInsets.only(top: 20),
                      width: double.infinity,
                      child: FilledButton(
                      style: buttonStyle,
                      child: Text('Register', style: headerStyle(level: 2)),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                    register();
                    }
                  }),
                  )
                ],),
              ),
            ),
            ]
          )
        )
      )
    );
  }
}
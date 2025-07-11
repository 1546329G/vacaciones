// lib/screens/cliente_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:my_first_app/models/user.dart'; // Importa tu modelo de User si lo vas a usar
import 'package:my_first_app/services/api_service.dart'; // Para obtener datos del usuario o cerrar sesión

// --- Modelos de Datos para la UI (usaremos dummy data por ahora) ---
// Normalmente, estos vendrían de tu API
class Category {
  final String name;
  final IconData icon; // O String imageUrl para iconos/imágenes de red

  Category({required this.name, required this.icon});
}

class Establishment {
  final String name;
  final String imageUrl;
  final String? slogan;
  final double rating;
  final String deliveryTime;
  final String deliveryCost;
  final String? discount;

  Establishment({
    required this.name,
    required this.imageUrl,
    this.slogan,
    required this.rating,
    required this.deliveryTime,
    required this.deliveryCost,
    this.discount,
  });
}

class PromotionBanner {
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final IconData icon;

  PromotionBanner({
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.icon,
  });
}

// --- CLASE DE LA PANTALLA PRINCIPAL ---
class ClienteDashboardScreen extends StatefulWidget {
  final User? currentUser; // Puedes pasar el usuario logueado

  const ClienteDashboardScreen({Key? key, this.currentUser}) : super(key: key);

  @override
  State<ClienteDashboardScreen> createState() => _ClienteDashboardScreenState();
}

class _ClienteDashboardScreenState extends State<ClienteDashboardScreen> {
  User? _user; // Para almacenar los datos del usuario actual
  String _currentLocation = 'Enviar a Lima'; // Ubicación de ejemplo

  @override
  void initState() {
    super.initState();
    _user = widget.currentUser; // Si se pasó un usuario inicial
    _fetchUserProfile(); // Intentar cargar el perfil más reciente
  }

  Future<void> _fetchUserProfile() async {
    try {
      final userProfile = await ApiService().getOwnProfile();
      setState(() {
        _user = userProfile;
      });
      print('Perfil de usuario cargado en el dashboard: ${_user?.nombre ?? _user?.email}');
    } catch (e) {
      print('Error al cargar el perfil del usuario: $e');
      // Podrías redirigir al login si el token es inválido aquí
    }
  }

  // --- DUMMY DATA (DATOS DE EJEMPLO) ---
  final List<Category> _categories = [
    Category(name: 'Restaurantes', icon: Icons.restaurant),
    Category(name: 'PedidosYa Market', icon: Icons.shopping_bag),
    Category(name: 'Bebidas', icon: Icons.local_bar),
    Category(name: 'Supermercados', icon: Icons.store),
    Category(name: 'Farmacias', icon: Icons.local_pharmacy),
    Category(name: 'Tiendas', icon: Icons.shopping_cart),
  ];

  final List<Establishment> _suggested = [
    Establishment(
      name: 'Xipe - Surquillo',
      imageUrl: 'https://via.placeholder.com/150/FF0000/FFFFFF?text=Xipe',
      rating: 4.5,
      deliveryTime: '15-30 min',
      deliveryCost: 'S/ 5.90',
    ),
    Establishment(
      name: 'Los Rolls De Diego - San Borja',
      imageUrl: 'https://via.placeholder.com/150/0000FF/FFFFFF?text=Rolls',
      rating: 4.6,
      deliveryTime: '20-35 min',
      deliveryCost: 'S/ 5.90',
    ),
    Establishment(
      name: 'Yopo - Aviacion',
      imageUrl: 'https://via.placeholder.com/150/00FF00/FFFFFF?text=Yopo',
      rating: 4.3,
      deliveryTime: '15-30 min',
      deliveryCost: 'S/ 5.90',
    ),
  ];

  final List<PromotionBanner> _promotionBanners = [
    PromotionBanner(
      title: 'Restaurantes',
      subtitle: '¡Disfruta estas promociones!',
      backgroundColor: Colors.yellow.shade700,
      icon: Icons.restaurant,
    ),
    PromotionBanner(
      title: 'Medios de pago',
      subtitle: '¡Conoce todas las opciones de ahorro!',
      backgroundColor: Colors.purple.shade700,
      icon: Icons.credit_card,
    ),
    PromotionBanner(
      title: 'Mercados',
      subtitle: '¡Conoce las promos y ahorra!',
      backgroundColor: Colors.lightBlue.shade700,
      icon: Icons.local_grocery_store,
    ),
  ];

  final List<Establishment> _discoverOptions = [
    Establishment(
      name: 'La Cusqueñita 939',
      imageUrl: 'https://via.placeholder.com/300/FF00FF/FFFFFF?text=Cusquenita',
      rating: 4.5,
      deliveryTime: '15-30 min',
      deliveryCost: 'S/ 5.90',
    ),
    Establishment(
      name: 'Caravana - San Borja',
      imageUrl: 'https://via.placeholder.com/300/00FFFF/FFFFFF?text=Caravana',
      rating: 4.1,
      deliveryTime: '20-35 min',
      deliveryCost: 'S/ 6.40',
      discount: 'Hasta 25% DSCTO',
    ),
    Establishment(
      name: 'Chifis Grulla',
      imageUrl: 'https://via.placeholder.com/300/FFFF00/000000?text=Chifis',
      rating: 4.5,
      deliveryTime: '20-35 min',
      deliveryCost: 'S/ 5.90',
    ),
  ];

  final List<Establishment> _discountOffers = [
    Establishment(
      name: 'Pardo´s',
      imageUrl: 'https://via.placeholder.com/300/FF5733/FFFFFF?text=Pardos',
      rating: 4.3,
      deliveryTime: '15-30 min',
      deliveryCost: 'S/ 5.90',
      discount: '10% DSCTO',
    ),
    Establishment(
      name: 'Mazar...',
      imageUrl: 'https://via.placeholder.com/300/33FF57/FFFFFF?text=Mazar',
      rating: 4.6,
      deliveryTime: '25-40 min',
      deliveryCost: 'S/ 5.90',
      discount: '20% DSCTO',
    ),
    Establishment(
      name: 'Ohash...',
      imageUrl: 'https://via.placeholder.com/300/3357FF/FFFFFF?text=Ohash',
      rating: 4.7,
      deliveryTime: '45-65 min',
      deliveryCost: 'S/ 6.40',
      discount: '25% DSCTO',
    ),
    Establishment(
      name: 'Tayppo...',
      imageUrl: 'https://via.placeholder.com/300/F533FF/FFFFFF?text=Tayppo',
      rating: 4.3,
      deliveryTime: '15-30 min',
      deliveryCost: 'S/ 5.90',
      discount: '25% DSCTO',
    ),
  ];

  final List<Establishment> _topRestaurants = [
    Establishment(
      name: 'McDonald\'s Ovalo Gutierrez',
      imageUrl: 'https://via.placeholder.com/300/FF0000/FFFFFF?text=McDonalds',
      rating: 4.3,
      deliveryTime: '20-35 min',
      deliveryCost: 'S/ 5.90',
    ),
    Establishment(
      name: 'Pollos De McDonald\'s Ovalo...',
      imageUrl: 'https://via.placeholder.com/300/0000FF/FFFFFF?text=Pollos',
      rating: 4.5,
      deliveryTime: '20-35 min',
      deliveryCost: 'S/ 5.90',
      discount: 'Hasta 20% DSCTO',
    ),
    Establishment(
      name: 'Restaurante Ok - Lima',
      imageUrl: 'https://via.placeholder.com/300/00FF00/FFFFFF?text=Ok',
      rating: 4.4,
      deliveryTime: '20-35 min',
      deliveryCost: 'S/ 5.90',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreetingSection(),
            _buildCategorySection(),
            _buildSectionHeader('Te sugerimos'),
            _buildSuggestedSection(),
            _buildSectionHeader('No te pierdas estas promociones'),
            _buildPromotionBanners(),
            _buildSectionHeader('Descubre estas opciones'),
            _buildDiscoverOptionsSection(),
            _buildSectionHeader('Aprovecha estos descuentos'),
            _buildDiscountOffersSection(),
            _buildSectionHeader('Restaurantes con el mejor precio'),
            _buildTopRestaurantsSection(),
            SizedBox(height: 20), // Espacio al final
          ],
        ),
      ),
    );
  }

  // --- Widgets de la AppBar ---
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.red.shade700,
      elevation: 0,
      toolbarHeight: 60,
      title: Row(
        children: [
          Image.network(
            'https://via.placeholder.com/50', // Reemplaza con el logo real de PedidosYa o tu app
            height: 30,
            width: 30,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  // Lógica para cambiar la ubicación
                  print('Cambiar ubicación');
                },
                child: Row(
                  children: [
                    Text(
                      'Enviar a $_currentLocation',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 16),
                  ],
                ),
              ),
              const Text(
                'Av. La Molina', // Aquí podrías poner la dirección exacta
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const Spacer(), // Empuja los siguientes elementos a la derecha
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              print('Buscar');
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white),
            onPressed: () {
              print('Ir a Mi Perfil');
              // Ejemplo: navegar a la pantalla de perfil del usuario
            },
          ),
        ],
      ),
      // Podrías añadir un Bottom aquí si la barra de búsqueda va debajo del logo
      // bottom: PreferredSize(
      //   preferredSize: Size.fromHeight(48.0),
      //   child: Padding(
      //     padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      //     child: TextField(
      //       decoration: InputDecoration(
      //         hintText: 'Buscar locales o platos',
      //         hintStyle: TextStyle(color: Colors.white70),
      //         prefixIcon: Icon(Icons.search, color: Colors.white70),
      //         filled: true,
      //         fillColor: Colors.white24,
      //         border: OutlineInputBorder(
      //           borderRadius: BorderRadius.circular(8.0),
      //           borderSide: BorderSide.none,
      //         ),
      //       ),
      //     ),
      //   ),
      // ),
    );
  }

  // --- Widgets de las secciones ---
  Widget _buildGreetingSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        'Hola${_user?.nombre != null ? ', ${_user!.nombre}' : ''}, ¿Qué vas a pedir hoy?',
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Container(
      height: 100, // Altura fija para la lista de categorías
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return GestureDetector(
            onTap: () {
              print('Categoría seleccionada: ${category.name}');
              // Lógica para navegar a la lista de locales de esa categoría
            },
            child: Container(
              width: 90, // Ancho fijo para cada categoría
              margin: const EdgeInsets.only(right: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey.shade200,
                    radius: 30,
                    child: Icon(category.icon, color: Colors.black54, size: 30),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    category.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          // Icono de flecha si es una sección que se puede deslizar o ver más
          if (title == 'Te sugerimos' || title == 'Descubre estas opciones' || title == 'Aprovecha estos descuentos' || title == 'Restaurantes con el mejor precio')
            const Icon(Icons.arrow_forward),
        ],
      ),
    );
  }

  Widget _buildSuggestedSection() {
    return Container(
      height: 150, // Altura fija para los elementos sugeridos
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: _suggested.length,
        itemBuilder: (context, index) {
          final item = _suggested[index];
          return _buildEstablishmentCard(item, width: 180, showDelivery: false, showRating: false);
        },
      ),
    );
  }

  Widget _buildPromotionBanners() {
    return Container(
      height: 120, // Altura fija para los banners de promoción
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: _promotionBanners.length,
        itemBuilder: (context, index) {
          final banner = _promotionBanners[index];
          return GestureDetector(
            onTap: () {
              print('Banner de promoción: ${banner.title}');
              // Lógica para ir a la sección de promociones
            },
            child: Container(
              width: 180, // Ancho fijo para cada banner
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: banner.backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      banner.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      banner.subtitle,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const Spacer(),
                    Icon(banner.icon, color: Colors.white, size: 30),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDiscoverOptionsSection() {
    return Container(
      height: 250, // Altura para los elementos de "Descubre"
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: _discoverOptions.length,
        itemBuilder: (context, index) {
          final item = _discoverOptions[index];
          return _buildEstablishmentCard(item, width: 220); // Ancho mayor para estos
        },
      ),
    );
  }

  Widget _buildDiscountOffersSection() {
    return Container(
      height: 200, // Altura para los elementos de descuento
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: _discountOffers.length,
        itemBuilder: (context, index) {
          final item = _discountOffers[index];
          return _buildEstablishmentCard(item, width: 150, showDiscount: true);
        },
      ),
    );
  }

  Widget _buildTopRestaurantsSection() {
    return Container(
      height: 200, // Altura para los restaurantes top
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: _topRestaurants.length,
        itemBuilder: (context, index) {
          final item = _topRestaurants[index];
          return _buildEstablishmentCard(item, width: 220, showDiscount: true);
        },
      ),
    );
  }

  // Widget reutilizable para mostrar un establecimiento/plato
  Widget _buildEstablishmentCard(
    Establishment item, {
    double width = 150,
    bool showDelivery = true,
    bool showRating = true,
    bool showDiscount = false,
  }) {
    return GestureDetector(
      onTap: () {
        print('Elemento seleccionado: ${item.name}');
        // Lógica para navegar a la pantalla de detalles del establecimiento/plato
      },
      child: Container(
        width: width,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  child: Image.network(
                    item.imageUrl,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                if (showDiscount && item.discount != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.yellow.shade600, // Color de descuento
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.discount!,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.slogan != null)
                    Text(
                      item.slogan!,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (showRating)
                        Icon(Icons.star, color: Colors.amber, size: 16),
                      if (showRating)
                        Text(
                          '${item.rating}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      if (showRating) const SizedBox(width: 8),
                      if (showDelivery)
                        Text(
                          '${item.deliveryTime} · ${item.deliveryCost}',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
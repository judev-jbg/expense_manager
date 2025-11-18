import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../data/models/adjunto_model.dart';

class AdjuntosGallery extends StatelessWidget {
  final List<AdjuntoModel> adjuntos;
  final Function(AdjuntoModel) onEliminar;
  final VoidCallback onAgregar;

  const AdjuntosGallery({
    Key? key,
    required this.adjuntos,
    required this.onEliminar,
    required this.onAgregar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Adjuntos (${adjuntos.length}/10)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: adjuntos.length < 10 ? onAgregar : null,
              icon: Icon(Icons.add),
              label: Text('Agregar'),
            ),
          ],
        ),
        SizedBox(height: 8),
        if (adjuntos.isEmpty)
          Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.attach_file, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Sin adjuntos', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: adjuntos.length,
            itemBuilder: (context, index) {
              final adjunto = adjuntos[index];
              return _buildAdjuntoCard(context, adjunto);
            },
          ),
      ],
    );
  }

  Widget _buildAdjuntoCard(BuildContext context, AdjuntoModel adjunto) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: adjunto.esImagen
                ? Image.file(
                    File(adjunto.rutaLocal),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      );
                    },
                  )
                : Container(
                    color: Colors.red.shade50,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.picture_as_pdf,
                            size: 32,
                            color: Colors.red.shade700,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'PDF',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
        // Botón eliminar
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => onEliminar(adjunto),
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
        // Tamaño del archivo
        Positioned(
          bottom: 4,
          left: 4,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              adjunto.tamanioFormateado,
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
        ),
      ],
    );
  }
}

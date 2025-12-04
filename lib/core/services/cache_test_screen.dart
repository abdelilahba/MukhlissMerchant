import 'package:flutter/material.dart';
import 'package:mukhlissmagasin/core/services/subscription_service.dart';

/// 🧪 Écran de Test du Cache
/// 
/// À ajouter temporairement pour tester le cache
/// 
/// Usage:
/// Navigator.push(context, MaterialPageRoute(
///   builder: (_) => CacheTestScreen(magasinId: 'votre_id'),
/// ));
class CacheTestScreen extends StatefulWidget {
  final String magasinId;

  const CacheTestScreen({
    super.key,
    required this.magasinId,
  });

  @override
  State<CacheTestScreen> createState() => _CacheTestScreenState();
}

class _CacheTestScreenState extends State<CacheTestScreen> {
  final _service = SubscriptionService();
  final List<TestResult> _results = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧪 Test Cache'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _clearResults,
            tooltip: 'Effacer résultats',
          ),
        ],
      ),
      body: Column(
        children: [
          // Boutons de test
          _buildTestButtons(),
          
          // Stats du cache
          _buildCacheStats(),
          
          // Résultats
          Expanded(
            child: _buildResultsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTestButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '🎯 Tests Disponibles',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          
          ElevatedButton(
            onPressed: _isLoading ? null : _testSingleCall,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('1️⃣ Appel Simple'),
          ),
          
          const SizedBox(height: 8),
          
          ElevatedButton(
            onPressed: _isLoading ? null : _testCacheHit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('2️⃣ Test Cache (2 appels)'),
          ),
          
          const SizedBox(height: 8),
          
          ElevatedButton(
            onPressed: _isLoading ? null : _testMultiple,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
            child: const Text('3️⃣ Test Multiple (10 appels)'),
          ),
          
          const SizedBox(height: 8),
          
          ElevatedButton(
            onPressed: _invalidateCache,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('🗑️ Vider Cache'),
          ),
        ],
      ),
    );
  }

  Widget _buildCacheStats() {
    final stats = _service.cacheStats;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 Statistiques Cache',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('Taille: ${stats.size} / ${stats.maxSize}'),
          Text('Hits: ${stats.hits} (succès)'),
          Text('Misses: ${stats.misses} (échecs)'),
          Text('Hit Rate: ${(stats.hitRate * 100).toStringAsFixed(1)}%'),
          
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: stats.hitRate,
            backgroundColor: Colors.red[100],
            valueColor: AlwaysStoppedAnimation(
              stats.hitRate > 0.8 ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    if (_results.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.science, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Lancez un test pour voir les résultats',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final result = _results[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(
              result.fromCache ? Icons.flash_on : Icons.cloud_download,
              color: result.fromCache ? Colors.green : Colors.blue,
            ),
            title: Text(
              result.fromCache ? 'Cache Hit ⚡' : 'API Call 🌐',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: result.fromCache ? Colors.green : Colors.blue,
              ),
            ),
            subtitle: Text(
              'Durée: ${result.duration}ms\n'
              'Status: ${result.status}',
            ),
            isThreeLine: true,
            trailing: Text(
              '#${index + 1}',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        );
      },
    );
  }

  // Tests

  Future<void> _testSingleCall() async {
    setState(() => _isLoading = true);
    
    final sw = Stopwatch()..start();
    final result = await _service.checkAccess(widget.magasinId);
    sw.stop();
    
    final stats = _service.cacheStats;
    final wasCached = stats.hits > 0;
    
    setState(() {
      _results.add(TestResult(
        fromCache: wasCached,
        duration: sw.elapsedMilliseconds,
        status: result.status,
      ));
      _isLoading = false;
    });
    
    _showSnackbar('Test terminé: ${sw.elapsedMilliseconds}ms');
  }

  Future<void> _testCacheHit() async {
    setState(() => _isLoading = true);
    
    // 1er appel (API)
    var sw = Stopwatch()..start();
    var result = await _service.checkAccess(widget.magasinId);
    sw.stop();
    
    setState(() {
      _results.add(TestResult(
        fromCache: false,
        duration: sw.elapsedMilliseconds,
        status: result.status,
      ));
    });
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    // 2ème appel (Cache)
    sw = Stopwatch()..start();
    result = await _service.checkAccess(widget.magasinId);
    sw.stop();
    
    setState(() {
      _results.add(TestResult(
        fromCache: true,
        duration: sw.elapsedMilliseconds,
        status: result.status,
      ));
      _isLoading = false;
    });
    
    _showSnackbar('Gain: ${(_results[_results.length - 2].duration / sw.elapsedMilliseconds).toStringAsFixed(0)}x plus rapide!');
  }

  Future<void> _testMultiple() async {
    setState(() => _isLoading = true);
    
    for (int i = 0; i < 10; i++) {
      final sw = Stopwatch()..start();
      final result = await _service.checkAccess(widget.magasinId);
      sw.stop();
      
      final stats = _service.cacheStats;
      final wasCached = i > 0; // Après le 1er, tous en cache
      
      setState(() {
        _results.add(TestResult(
          fromCache: wasCached,
          duration: sw.elapsedMilliseconds,
          status: result.status,
        ));
      });
      
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    setState(() => _isLoading = false);
    _showSnackbar('10 appels terminés!');
  }

  Future<void> _invalidateCache() async {
    await _service.invalidateCache(widget.magasinId);
    setState(() {});
    _showSnackbar('Cache vidé!');
  }

  void _clearResults() {
    setState(() => _results.clear());
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class TestResult {
  final bool fromCache;
  final int duration;
  final String status;

  TestResult({
    required this.fromCache,
    required this.duration,
    required this.status,
  });
}

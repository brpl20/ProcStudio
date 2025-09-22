/**
 * LawyerStore Console Test
 * Copy and paste this into your browser's console to test the store
 */

// Test the lawyer store manually in console
async function testLawyerStore() {
  console.log('🧪 Starting LawyerStore Tests...');
  
  try {
    // Import the store (adjust path if needed)
    const { lawyerStore } = await import('./lawyerStore.svelte.ts');
    
    console.log('✅ Store imported successfully');
    console.log('📊 Initial state:', {
      lawyers: lawyerStore.lawyers,
      loading: lawyerStore.loading,
      error: lawyerStore.error,
      initialized: lawyerStore.initialized,
      status: lawyerStore.status,
      isDisposed: lawyerStore.isDisposed
    });
    
    // Test 1: Initialize
    console.log('\n🔄 Test 1: Initialize store...');
    await lawyerStore.init();
    console.log('📊 After init:', {
      lawyers: lawyerStore.lawyers.length,
      initialized: lawyerStore.initialized,
      status: lawyerStore.status,
      error: lawyerStore.error
    });
    
    // Test 2: Fetch lawyers
    console.log('\n🔄 Test 2: Fetch lawyers...');
    await lawyerStore.fetchLawyers();
    console.log('📊 After fetch:', {
      lawyersCount: lawyerStore.lawyersCount,
      activeLawyersCount: lawyerStore.activeLawyers.length,
      availableLawyersCount: lawyerStore.availableLawyers.length,
      status: lawyerStore.status
    });
    
    // Log detailed breakdown
    console.log('📋 Lawyers breakdown:');
    console.log('  All lawyers:', lawyerStore.lawyers.map(l => ({
      name: l.attributes.name,
      status: l.attributes.status,
      deleted: l.attributes.deleted
    })));
    console.log('  Active lawyers:', lawyerStore.activeLawyers.map(l => ({
      name: l.attributes.name,
      status: l.attributes.status
    })));
    console.log('  Available lawyers:', lawyerStore.availableLawyers.map(l => ({
      name: l.attributes.name,
      status: l.attributes.status
    })));
    
    // Test 3: Selection
    if (lawyerStore.lawyers.length > 0) {
      console.log('\n🔄 Test 3: Selection...');
      const firstLawyer = lawyerStore.lawyers[0];
      console.log('Selecting lawyer:', firstLawyer.attributes.name);
      
      lawyerStore.selectLawyer(firstLawyer);
      console.log('📊 After selection:', {
        selectedCount: lawyerStore.selectedLawyersCount,
        remainingCount: lawyerStore.remainingLawyersCount
      });
      
      // Test unselect
      lawyerStore.unselectLawyer(firstLawyer.id);
      console.log('📊 After unselect:', {
        selectedCount: lawyerStore.selectedLawyersCount,
        remainingCount: lawyerStore.remainingLawyersCount
      });
    }
    
    // Test 4: Refresh
    console.log('\n🔄 Test 4: Refresh...');
    await lawyerStore.refresh();
    console.log('📊 After refresh:', {
      status: lawyerStore.status,
      lawyersCount: lawyerStore.lawyersCount
    });
    
    // Test 5: Cancel
    console.log('\n🔄 Test 5: Cancel...');
    lawyerStore.cancel();
    console.log('📊 After cancel:', {
      status: lawyerStore.status,
      loading: lawyerStore.loading
    });
    
    console.log('\n✅ All tests completed successfully!');
    
    // Return store for manual testing
    window.lawyerStoreTest = lawyerStore;
    console.log('💡 Store available as window.lawyerStoreTest for manual testing');
    
  } catch (error) {
    console.error('❌ Test failed:', error);
    console.error('Stack:', error.stack);
  }
}

// Utility functions for manual testing
window.testLawyerStore = testLawyerStore;

// Quick access functions
window.lawyerStoreMethods = {
  async init() {
    const { lawyerStore } = await import('./lawyerStore.svelte.ts');
    await lawyerStore.init();
    console.log('Initialized:', lawyerStore.status);
  },
  
  async fetch() {
    const { lawyerStore } = await import('./lawyerStore.svelte.ts');
    await lawyerStore.fetchLawyers();
    console.log('Fetched:', lawyerStore.lawyersCount, 'lawyers');
  },
  
  async getState() {
    const { lawyerStore } = await import('./lawyerStore.svelte.ts');
    return {
      lawyers: lawyerStore.lawyers,
      activeLawyers: lawyerStore.activeLawyers,
      availableLawyers: lawyerStore.availableLawyers,
      selectedLawyers: lawyerStore.selectedLawyers,
      loading: lawyerStore.loading,
      error: lawyerStore.error,
      initialized: lawyerStore.initialized,
      status: lawyerStore.status,
      lawyersCount: lawyerStore.lawyersCount,
      activeLawyersCount: lawyerStore.activeLawyers.length,
      availableLawyersCount: lawyerStore.availableLawyers.length,
      selectedLawyersCount: lawyerStore.selectedLawyersCount,
      remainingLawyersCount: lawyerStore.remainingLawyersCount,
      isDisposed: lawyerStore.isDisposed
    };
  },

  async getActiveLawyers() {
    const { lawyerStore } = await import('./lawyerStore.svelte.ts');
    return lawyerStore.activeLawyers.map(lawyer => ({
      id: lawyer.id,
      name: lawyer.attributes.name,
      lastName: lawyer.attributes.last_name,
      status: lawyer.attributes.status,
      oab: lawyer.attributes.oab,
      deleted: lawyer.attributes.deleted
    }));
  },

  async getAvailableLawyers() {
    const { lawyerStore } = await import('./lawyerStore.svelte.ts');
    return lawyerStore.availableLawyers.map(lawyer => ({
      id: lawyer.id,
      name: lawyer.attributes.name,
      lastName: lawyer.attributes.last_name,
      status: lawyer.attributes.status,
      oab: lawyer.attributes.oab,
      selected: lawyerStore.selectedLawyers.some(s => s.id === lawyer.id)
    }));
  }
};

console.log(`
🧪 LawyerStore Console Test Loaded!

Usage:
1. Run full test: testLawyerStore()
2. Get current state: lawyerStoreMethods.getState()
3. Initialize: lawyerStoreMethods.init()
4. Fetch: lawyerStoreMethods.fetch()

After running testLawyerStore(), the store will be available as window.lawyerStoreTest
`);
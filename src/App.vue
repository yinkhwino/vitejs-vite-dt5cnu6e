<template>
<!--please add Dashboard component here and disabled my Login form 
- <div class="auth-container">.....</div>
add <Dashboard />
-->
  <div class="auth-container">
    <div v-if="error" class="alert alert-error">
      <span>{{ error }}</span>
    </div>

    <div v-if="!user" class="hero bg-base-200 min-h-screen">
      <div class="hero-content flex-col lg:flex-row-reverse">
        <div class="text-center lg:text-left">
          <h1 class="text-2xl font-bold">Login now!</h1>
          <p class="py-6">
            Welcome to the Inventory Optimiser. Please sign in to manage your
            plane parts inventory.
          </p>
        </div>
        <label class="input input-bordered flex items-center gap-2">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 16 16"
            fill="currentColor"
            class="h-4 w-4 opacity-70"
          >
            <path
              d="M2.5 3A1.5 1.5 0 0 0 1 4.5v.793c.026.009.051.02.076.032L7.674 8.51c.206.1.446.1.652 0l6.598-3.185A.755.755 0 0 1 15 5.293V4.5A1.5 1.5 0 0 0 13.5 3h-11Z"
            />
            <path
              d="M15 6.954 8.978 9.86a2.25 2.25 0 0 1-1.956 0L1 6.954V11.5A1.5 1.5 0 0 0 2.5 13h11a1.5 1.5 0 0 0 1.5-1.5V6.954Z"
            />
          </svg>
          <input type="text" class="grow" placeholder="Email" v-model="email" />
        </label>
        <label class="input input-bordered flex items-center gap-2">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 16 16"
            fill="currentColor"
            class="h-4 w-4 opacity-70"
          >
            <path
              fill-rule="evenodd"
              d="M14 6a4 4 0 0 1-4.899 3.899l-1.955 1.955a.5.5 0 0 1-.353.146H5v1.5a.5.5 0 0 1-.5.5h-2a.5.5 0 0 1-.5-.5v-2.293a.5.5 0 0 1 .146-.353l3.955-3.955A4 4 0 1 1 14 6Zm-4-2a.75.75 0 0 0 0 1.5.5.5 0 0 1 .5.5.75.75 0 0 0 1.5 0 2 2 0 0 0-2-2Z"
              clip-rule="evenodd"
            />
          </svg>
          <input
            type="password"
            class="grow"
            placeholder="Password"
            v-model="password"
          />
        </label>
        <button
          class="btn btn-wide bg-[#0B2265] text-white"
          :disabled="authLoading"
          @click="signIn"
        >
          {{ authLoading ? 'Loading...' : 'Sign In' }}
        </button>
        <button
          class="btn btn-ghost"
          :disabled="authLoading"
          @click="handleSignUp"
        >
          Sign Up
        </button>
      </div>
    </div>

    <div v-else class="min-h-screen flex flex-col">
      <div class="navbar bg-[#0B2265] text-white">
        <div class="navbar-start">
          <div class="dropdown">
            <div tabindex="0" role="button" class="btn btn-ghost btn-circle">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="h-5 w-5"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M4 6h16M4 12h16M4 18h7"
                />
              </svg>
            </div>
            <ul
              tabindex="0"
              class="menu menu-sm dropdown-content mt-3 z-[1] p-2 shadow bg-base-100 rounded-box w-52 text-black"
            >
              <li><router-link to="/">Dashboard</router-link></li>
              <li><router-link to="/order">Order</router-link></li>
            </ul>
          </div>
        </div>
        <div class="navbar-center">
          <router-link to="/" class="btn btn-ghost text-xl text-white"
            >Inventory Optimiser</router-link
          >
        </div>
        <div class="navbar-end">
          <div class="flex items-center gap-4">
            <span class="text-sm">{{ user.email }}</span>
            <button class="btn btn-ghost btn-sm text-white" @click="signOut">
              Sign Out
            </button>
          </div>
        </div>
      </div>

      <div class="flex-grow">
        <router-view v-if="$route.path !== '/'" />
        <div role="tablist" class="tabs tabs-lifted">
          <input type="radio" name="subnetwork" role="tab" class="tab" aria-label="Compressor" />
            <div role="tabpanel" class="tab-content bg-base-100 border-base-300 rounded-box p-6">
                
                <div><Order /></div>
            </div>

          <input type="radio" name="subnetwork" role="tab" class="tab" aria-label="Turbine" checked="checked" />
            <div role="tabpanel" class="tab-content bg-base-100 border-base-300 rounded-box p-6">
                Tab content 2
            </div>

          <input type="radio" name="subnetwork" role="tab" class="tab" aria-label="Combustor" />
            <div role="tabpanel" class="tab-content bg-base-100 border-base-300 rounded-box p-6">
                Tab content 3
            </div>
        </div>
        
      </div>

      <footer class="footer footer-center p-4 bg-[#0B2265] text-white">
        <aside>
          <p>© 2025 - Inventory Optimiser by GE Aerospace</p>
        </aside>
      </footer>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { supabase } from './lib/supabaseClient';
import Order from './components/Order.vue';
import PlanePart from './components/PlanePart.vue';

const router = useRouter();
const authLoading = ref(false);
const loading = ref(false);
const email = ref('');
const password = ref('');
const error = ref('');
const user = ref(null);
const components = ref([]);

onMounted(async () => {
  try {
    // Check for existing session
    const { data: { session }, error: sessionError } = await supabase.auth.getSession();
    if (sessionError) throw sessionError;
    
    if (session) {
      user.value = session.user;
      await loadInventory();
    }

    // Listen for auth changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange(async (event, session) => {
      if (event === 'SIGNED_IN') {
        user.value = session.user;
        await loadInventory();
      } else if (event === 'SIGNED_OUT') {
        user.value = null;
        components.value = [];
        router.push('/');
      } else if (event === 'TOKEN_REFRESHED') {
        if (session) {
          user.value = session.user;
        }
      }
    });

    // Cleanup subscription on component unmount
    return () => {
      subscription.unsubscribe();
    };
  } catch (err) {
    console.error('Session initialization error:', err);
    error.value = 'Error initializing session';
  }
});

const handleSignUp = async () => {
  if (!email.value || !password.value) {
    error.value = 'Please enter both email and password';
    return;
  }

  authLoading.value = true;
  error.value = '';

  try {
    const { data, error: signUpError } = await supabase.auth.signUp({
      email: email.value,
      password: password.value,
    });

    if (signUpError) throw signUpError;

    if (data.user) {
      error.value = 'Successfully signed up! You can now sign in.';
      email.value = '';
      password.value = '';
    }
  } catch (err) {
    error.value = err.message;
  } finally {
    authLoading.value = false;
  }
};

const signIn = async () => {
  if (!email.value || !password.value) {
    error.value = 'Please enter both email and password';
    return;
  }

  authLoading.value = true;
  error.value = '';

  try {
    const { data, error: signInError } = await supabase.auth.signInWithPassword({
      email: email.value,
      password: password.value,
    });

    if (signInError) throw signInError;

    if (data.user) {
      email.value = '';
      password.value = '';
    }
  } catch (err) {
    error.value = err.message;
  } finally {
    authLoading.value = false;
  }
};

const loadInventory = async () => {
  if (!user.value) return;
  
  loading.value = true;
  error.value = null;
  
  try {
    const { data, error: queryError } = await supabase
      .from('components')
      .select('*')
      .eq('user_id', user.value.id)
      .order('created_at');

    if (queryError) throw queryError;
    components.value = data || [];
  } catch (err) {
    console.error('Error loading components:', err);
    error.value = 'Error loading components: ' + err.message;
  } finally {
    loading.value = false;
  }
};

const signOut = async () => {
  try {
    const { error: signOutError } = await supabase.auth.signOut();
    if (signOutError) throw signOutError;
  } catch (err) {
    error.value = 'Error signing out: ' + err.message;
  }
};
</script>

<style scoped>
.auth-container {
  max-width: 100%;
  margin: 0 auto;
}

.alert {
  margin-bottom: 1rem;
  padding: 1rem;
  border-radius: 0.5rem;
}

.alert-error {
  background-color: #fee2e2;
  color: #dc2626;
}
</style>
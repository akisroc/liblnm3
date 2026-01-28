import { fail, redirect } from '@sveltejs/kit';
import { PLATFORM_URL_INTERNAL } from '$env/static/private';
import type { Actions } from './$types';

export const actions = {
	register_user: async ({ request, fetch }) => {
		const data = await request.formData();
		const nickname = data.get('nickname');
		const email = data.get('email');
		const password = data.get('password');

		const payload = { nickname, email, password };

		try {
			const response = await fetch(`${PLATFORM_URL_INTERNAL}/register-user`, {
				method: 'POST',
				headers: {
					'Content-Type': 'application/json',
					'Accept': 'application/json',
					'Accept-Encoding': 'identity'
				},
				body: JSON.stringify(payload)
			})

			const result = await response.json();

			if (!response.ok) {
				return fail(response.status, {
					error: true,
					message: result.errors ? "Erreur de validation" : result.message,
					values: { nickname, email, password } // Todo
				})
			}
		} catch (error) {
			console.error('API error', error || 'Unknown error');
			return fail(500, {
				message: "Serveur injoignable",
				values: { nickname, email, password }
			})
		}

		throw redirect(303, '/onboarding/register-kingdom-and-leader')
	}
} satisfies Actions;

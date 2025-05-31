/* generated using openapi-typescript-codegen -- do not edit */
/* istanbul ignore file */
/* tslint:disable */
/* eslint-disable */
import type { Agent } from '../models/Agent';
import type { Proposal } from '../models/Proposal';
import type { CancelablePromise } from '../core/CancelablePromise';
import { OpenAPI } from '../core/OpenAPI';
import { request as __request } from '../core/request';
export class DefaultService {
    /**
     * List all agents
     * @returns Agent A list of agents
     * @throws ApiError
     */
    public static mainGetAgents(): CancelablePromise<Array<Agent>> {
        return __request(OpenAPI, {
            method: 'GET',
            url: '/agents',
        });
    }
    /**
     * Register a new agent
     * @param requestBody
     * @returns any Agent created
     * @throws ApiError
     */
    public static mainPostAgents(
        requestBody: Agent,
    ): CancelablePromise<any> {
        return __request(OpenAPI, {
            method: 'POST',
            url: '/agents',
            body: requestBody,
            mediaType: 'application/json',
        });
    }
    /**
     * Get an agent by ID
     * @param id
     * @returns Agent Agent found
     * @throws ApiError
     */
    public static mainGetAgent(
        id: string,
    ): CancelablePromise<Agent> {
        return __request(OpenAPI, {
            method: 'GET',
            url: '/agents/{id}',
            path: {
                'id': id,
            },
            errors: {
                404: `Agent not found`,
            },
        });
    }
    /**
     * List all proposals
     * @returns Proposal A list of proposals
     * @throws ApiError
     */
    public static mainGetProposals(): CancelablePromise<Array<Proposal>> {
        return __request(OpenAPI, {
            method: 'GET',
            url: '/proposals',
        });
    }
    /**
     * Create a new proposal
     * @param requestBody
     * @returns any Proposal created
     * @throws ApiError
     */
    public static mainPostProposals(
        requestBody: Proposal,
    ): CancelablePromise<any> {
        return __request(OpenAPI, {
            method: 'POST',
            url: '/proposals',
            body: requestBody,
            mediaType: 'application/json',
        });
    }
    /**
     * Get a proposal by ID
     * @param id
     * @returns Proposal Proposal found
     * @throws ApiError
     */
    public static mainGetProposal(
        id: string,
    ): CancelablePromise<Proposal> {
        return __request(OpenAPI, {
            method: 'GET',
            url: '/proposals/{id}',
            path: {
                'id': id,
            },
            errors: {
                404: `Proposal not found`,
            },
        });
    }
    /**
     * Submit a vote on a proposal
     * @param id
     * @param requestBody
     * @returns any Vote submitted
     * @throws ApiError
     */
    public static mainPostProposalVote(
        id: string,
        requestBody: {
            voterId: string;
            vote: 'yes' | 'no' | 'abstain';
            reason?: string;
        },
    ): CancelablePromise<any> {
        return __request(OpenAPI, {
            method: 'POST',
            url: '/proposals/{id}/vote',
            path: {
                'id': id,
            },
            body: requestBody,
            mediaType: 'application/json',
        });
    }
}

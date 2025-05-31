/* generated using openapi-typescript-codegen -- do not edit */
/* istanbul ignore file */
/* tslint:disable */
/* eslint-disable */
import type { Agent } from './Agent';
export type Proposal = {
    id: string;
    title: string;
    description?: string;
    /**
     * Current state of the proposal in its lifecycle
     */
    status: Proposal.status;
    createdBy: Agent;
    createdAt: string;
    votes?: Array<{
        voter: Agent;
        vote: 'yes' | 'no' | 'abstain';
        reason?: string;
    }>;
};
export namespace Proposal {
    /**
     * Current state of the proposal in its lifecycle
     */
    export enum status {
        PENDING = 'Pending',
        ACTIVE = 'Active',
        CANCELED = 'Canceled',
        DEFEATED = 'Defeated',
        SUCCEEDED = 'Succeeded',
        QUEUED = 'Queued',
        EXPIRED = 'Expired',
        EXECUTED = 'Executed',
    }
}


/* generated using openapi-typescript-codegen -- do not edit */
/* istanbul ignore file */
/* tslint:disable */
/* eslint-disable */
export type Proposal = {
    proposalId: string;
    description?: string;
    /**
     * Current state of the proposal in its lifecycle
     */
    status: Proposal.status;
    createdBy: string;
    votes?: Array<{
        voterAddress?: string;
        weight?: string;
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
        ENDED = 'Ended',
        UNKNOWN = 'unknown',
    }
}

